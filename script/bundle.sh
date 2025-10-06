#!/usr/bin/env bash
set -euo pipefail

# Config
APP=db
DB_NAME=${DB_NAME:-bankencorre_development}
BUNDLE_DIR=${BUNDLE_DIR:-review_bundle}
SQL_DIR="$BUNDLE_DIR/sql"
DOCS_DIR="$BUNDLE_DIR/docs"
MIG_DIR="$BUNDLE_DIR/migrations"
SEEDS_DIR="$BUNDLE_DIR/seeds"
INCLUDE_SQL_REFS=${INCLUDE_SQL_REFS:-1}   # 1 = dump ref tables, 0 = skip
INCLUDE_FULL_STRUCTURE=${INCLUDE_FULL_STRUCTURE:-0} # 1 = db:structure:dump, 0 = db:schema:dump

mkdir -p "$BUNDLE_DIR" "$SQL_DIR" "$DOCS_DIR" "$MIG_DIR" "$SEEDS_DIR"

echo "==> Dump schema/structure"
if [[ "$INCLUDE_FULL_STRUCTURE" == "1" ]]; then
  bin/rails db:structure:dump
  cp db/structure.sql "$BUNDLE_DIR/structure.sql"
else
  bin/rails db:schema:dump
  cp db/schema.rb "$BUNDLE_DIR/schema.rb"
fi

echo "==> Copy targeted migrations (parties/links/refs only)"
# adjust patterns only as needed
grep -lE '(party_links|party_link_suggestions|ref_party_link_types|party_groups|party_group_suggestions|date_bounds|covering_indexes)' db/migrate/*.rb \
  | xargs -I {} cp {} "$MIG_DIR/"

echo "==> Copy seed files for link types and groups"
# Ruby seeds
[[ -f db/seeds/20251006_party_link_types.rb ]] && cp db/seeds/20251006_party_link_types.rb "$SEEDS_DIR/20251006_party_link_types.rb"
# SQL seeds (reference catalogs)
for f in db/seeds/ref_party_link_types.sql db/seeds/ref_party_group_types.sql db/seeds/party_link_group_types.sql; do
  [[ -f "$f" ]] && cp "$f" "$SEEDS_DIR/$(basename "$f")"
done

echo "==> Create tiny demo seed (deterministic, safe)"
cat > "$SEEDS_DIR/demo_parties_links.rb" <<'RUBY'
# Minimal demo data to exercise UI. No PII.
ActiveRecord::Base.transaction do
  # Parties
  person = Party::Person.find_or_create_by!(public_id: '00000000-0000-0000-0000-000000000001') do |p|
    p.first_name = 'Alex'; p.last_name = 'Demo'; p.primary = true
  end
  org = Party::Organization.find_or_create_by!(public_id: '00000000-0000-0000-0000-000000000010') do |o|
    o.legal_name = 'Demo Org LLC'; o.primary = true
  end

  # Ensure reference link types exist if seeds not run
  plt = Ref::PartyLinkType.find_by(code: 'employer_of') || Ref::PartyLinkType.create!(
    code: 'employer_of', name: 'Employer Of', symmetric: false,
    allowed_from_party_types: %w[organization],
    allowed_to_party_types: %w[person]
  )
  inverse = Ref::PartyLinkType.find_by(code: 'employee_of') || Ref::PartyLinkType.create!(
    code: 'employee_of', name: 'Employee Of', symmetric: false,
    inverse_code: 'employer_of',
    allowed_from_party_types: %w[person],
    allowed_to_party_types: %w[organization]
  )
  plt.update!(inverse_code: 'employee_of') if plt.inverse_code != 'employee_of'

  # Link
  Party::Link.find_or_create_by!(from_party: org, to_party: person, link_type_code: 'employer_of') do |l|
    l.started_on = Date.new(2020,1,1)
  end
end
RUBY

echo "==> Copy ADRs and relationship docs"
# Core ADRs that define link semantics and guards
for adr in 0034-date-bounded-links.md 0035-catalog-driven-validations.md 0036-mariadb-index-strategy.md 0037-inverse-links-and-symmetry.md 0038-group-membership-overlap-and-roles.md 0039-suggest-dont-autocreate.md 0040-catalog-normalization-and-backfill.md; do
  [[ -f "docs/adrs/$adr" ]] && cp "docs/adrs/$adr" "$DOCS_DIR/$adr"
done
# Helpful overviews if present
for doc in OVERVIEW.md domain.md migrations.md; do
  [[ -f "docs/$doc" ]] && cp "docs/$doc" "$DOCS_DIR/$doc"
done

echo "==> Optional: SQL dump of reference tables only"
if [[ "$INCLUDE_SQL_REFS" == "1" ]]; then
  # Safe, small catalogs only. No PII.
  sudo mysqldump "$DB_NAME" \
    ref_party_link_types ref_party_group_types ref_identifier_types ref_countries ref_regions \
    > "$SQL_DIR/reference_catalogs.sql"
fi

echo "==> VERSION and MANIFEST"
GIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "nogit")
DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "${DATE}+${GIT_SHA}" > "$BUNDLE_DIR/VERSION.txt"

# SHASUMS and MANIFEST.json
( cd "$BUNDLE_DIR" && \
  find . -type f -not -name 'SHASUMS' -print0 | sort -z | xargs -0 sha256sum > SHASUMS )

# Build MANIFEST.json programmatically
python3 - "$BUNDLE_DIR" <<'PY'
import hashlib, json, os, sys
root = sys.argv[1]
files = {}
for dirpath, _, filenames in os.walk(root):
    for fn in filenames:
        if fn == 'MANIFEST.json': continue
        p = os.path.join(dirpath, fn)
        rel = os.path.relpath(p, root)
        with open(p, 'rb') as f:
            h = hashlib.sha256(f.read()).hexdigest()
        files[rel] = f"sha256:{h}"
manifest = {
  "version": open(os.path.join(root, "VERSION.txt")).read().strip(),
  "files": files
}
with open(os.path.join(root, "MANIFEST.json"), "w") as f:
    json.dump(manifest, f, indent=2, sort_keys=True)
PY

echo "==> Done. Output in $BUNDLE_DIR"

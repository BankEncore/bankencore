module Party
  module Suggestions
    class LinkRules
      Result = Struct.new(:source_party_id, :target_party_id, :suggested_link_type_code, :confidence, :detected_by, :evidence, keyword_init: true)

      def self.run(limit: 10_000) = new.run(limit:)
      def run(limit:) = same_address_spouse_candidates(limit:) +
                        employer_domain_candidates(limit:) +
                        org_hierarchy_ein_prefix_candidates(limit:)

      private

      # People at same residential address + same last name -> spouse_of
      def same_address_spouse_candidates(limit:)
        sql = <<~SQL
          SELECT a1.party_id AS p1, a2.party_id AS p2,
                LOWER(SUBSTRING_INDEX(pp1.last_name, ' ', 1)) AS ln
          FROM party_addresses a1
          JOIN party_addresses a2
            ON a1.line1 = a2.line1
          AND a1.postal_code = a2.postal_code
          AND a1.country_code = a2.country_code
          JOIN party_people pp1 ON pp1.party_id = a1.party_id
          JOIN party_people pp2 ON pp2.party_id = a2.party_id
          JOIN parties p1 ON p1.id = pp1.party_id AND p1.party_type = 'person'
          JOIN parties p2 ON p2.id = pp2.party_id AND p2.party_type = 'person'
          WHERE a1.party_id < a2.party_id
            AND a1.address_type_code = 'residential'
            AND a2.address_type_code = 'residential'
            AND LOWER(SUBSTRING_INDEX(pp1.last_name, ' ', 1)) = LOWER(SUBSTRING_INDEX(pp2.last_name, ' ', 1))
          LIMIT #{limit.to_i}
        SQL
        rows = ActiveRecord::Base.connection.exec_query(sql)
        rows.map { |r|
          Result.new(
            source_party_id: r["p1"], target_party_id: r["p2"],
            suggested_link_type_code: "spouse_of",
            confidence: 0.85, detected_by: "same_address_lastname",
            evidence: { last_name: r["ln"] }
          )
        }
      end

      # Person email domain matches org website/email domain -> employer_of
      def employer_domain_candidates(limit:)
        sql = <<~SQL
          WITH person_emails AS (
            SELECT pe.party_id, LOWER(pe.domain) AS domain
            FROM party_emails pe
            JOIN parties pp ON pp.id = pe.party_id AND pp.party_type = 'person'
            WHERE pe.domain IS NOT NULL
          ), org_emails AS (
            SELECT oe.party_id, LOWER(oe.domain) AS domain
            FROM party_emails oe
            JOIN parties po ON po.id = oe.party_id AND po.party_type = 'organization'
            WHERE oe.domain IS NOT NULL
          )
          SELECT DISTINCT pe.party_id AS person_id, oe.party_id AS org_id, pe.domain
          FROM person_emails pe
          JOIN org_emails  oe ON pe.domain = oe.domain
          LIMIT #{limit.to_i}
        SQL
        rows = ActiveRecord::Base.connection.exec_query(sql)
        rows.map do |r|
          Result.new(
            source_party_id: r["org_id"], target_party_id: r["person_id"],
            suggested_link_type_code: "employer_of",
            confidence: 0.70, detected_by: "email_domain_match",
            evidence: { domain: r["domain"] }
          )
        end
      end

      # Orgs with matching EIN prefix -> parent_company_of
      # Use party_identifiers instead of encrypted parties.tax_id
      def org_hierarchy_ein_prefix_candidates(limit:)
        sql = <<~SQL
          WITH org_eins AS (
            SELECT pi.party_id,
                  REPLACE(REPLACE(LOWER(pi.value), '-', ''), ' ', '') AS ein_norm
            FROM party_identifiers pi
            JOIN parties p ON p.id = pi.party_id AND p.party_type = 'organization'
            WHERE pi.id_type_code = 'ein' AND pi.value IS NOT NULL
          )
          SELECT oe1.party_id AS parent_id, oe2.party_id AS child_id, LEFT(oe1.ein_norm, 8) AS pref
          FROM org_eins oe1
          JOIN org_eins oe2
            ON oe1.party_id <> oe2.party_id
          AND LEFT(oe1.ein_norm, 8) = LEFT(oe2.ein_norm, 8)
          LIMIT #{limit.to_i}
        SQL
        rows = ActiveRecord::Base.connection.exec_query(sql)
        rows.map { |r|
          Result.new(
            source_party_id: r["parent_id"], target_party_id: r["child_id"],
            suggested_link_type_code: "parent_company_of",
            confidence: 0.55, detected_by: "ein_prefix",
            evidence: { ein_prefix: r["pref"] }
          )
        }
      end
    end
  end
end

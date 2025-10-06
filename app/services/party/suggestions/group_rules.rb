# app/services/party/suggestions/group_rules.rb
class Party::Suggestions::GroupRules
  Result = Struct.new(:group_type_code, :name, :members, :confidence, :detected_by, :evidence, keyword_init: true)

  def self.run(limit: 500) = new.run(limit:)

  def run(limit:)
    households_by_address(limit:) + corporate_families(limit:)
  end

  private

  # People at same residential address -> household suggestion
  def households_by_address(limit:)
    sql = <<~SQL
      SELECT a.country_code, a.region_code, a.postal_code, a.locality, a.line1,
             JSON_ARRAYAGG(a.party_id) AS ids
      FROM party_addresses a
      JOIN parties p ON p.id=a.party_id AND p.party_type='person'
      WHERE a.address_type_code='residential'
      GROUP BY a.country_code, a.region_code, a.postal_code, a.locality, a.line1
      HAVING COUNT(*) >= 2
      LIMIT #{limit.to_i}
    SQL
    rows = ActiveRecord::Base.connection.exec_query(sql)
    rows.map do |r|
      ids = JSON.parse(r["ids"]).uniq
      members = ids.map.with_index { |pid, i| { party_id: pid, role_code: (i.zero? ? "head" : "member") } }
      Result.new(
        group_type_code: "household",
        name: nil,
        members: members,
        confidence: 0.8,
        detected_by: "shared_residential_address",
        evidence: { address: r.slice("country_code", "region_code", "postal_code", "locality", "line1") }
      )
    end
  end

    # Orgs sharing EIN prefix -> corporate_family suggestion with simple parent/subsidiary proposal
    def corporate_families(limit:)
    sql = <<~SQL
        WITH org_eins AS (
        SELECT pi.party_id, REPLACE(REPLACE(LOWER(pi.value), '-', ''), ' ', '') AS ein_norm
        FROM party_identifiers pi
        JOIN parties p ON p.id = pi.party_id AND p.party_type = 'organization'
        WHERE pi.id_type_code = 'ein' AND pi.value IS NOT NULL
        )
        SELECT LEFT(oe1.ein_norm, 8) AS pref, JSON_ARRAYAGG(oe1.party_id) AS ids
        FROM org_eins oe1
        GROUP BY LEFT(oe1.ein_norm, 8)
        HAVING COUNT(*) >= 2
        LIMIT #{limit.to_i}
    SQL
    rows = ActiveRecord::Base.connection.exec_query(sql)
    rows.map do |r|
        ids = JSON.parse(r["ids"]).uniq
        members = [ { party_id: ids.first, role_code: "parent" } ] +
                ids.drop(1).map { |id| { party_id: id, role_code: "subsidiary" } }
        Result.new(
        group_type_code: "corporate_family",
        name: nil,
        members: members,
        confidence: 0.6,
        detected_by: "ein_prefix_cluster",
        evidence: { ein_prefix: r["pref"], size: ids.size }
        )
    end
    end
end

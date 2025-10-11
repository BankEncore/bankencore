# db/seeds/party_link_group_types.rb
Ref::PartyLinkType.upsert_all([
  { code: "spouse_of", name: "Spouse Of", inverse_code: "spouse_of",
    symmetric: true,  allowed_from_party_types: ["person"], allowed_to_party_types: ["person"],
    default_from_role: "spouse", default_to_role: "spouse" },
  { code: "parent_of", name: "Parent Of", inverse_code: "child_of",
    symmetric: false, allowed_from_party_types: ["person"], allowed_to_party_types: ["person"],
    default_from_role: "parent", default_to_role: "child" },
  { code: "child_of", name: "Child Of", inverse_code: "parent_of",
    symmetric: false, allowed_from_party_types: ["person"], allowed_to_party_types: ["person"],
    default_from_role: "child", default_to_role: "parent" },
  { code: "employee_of", name: "Employee Of", inverse_code: "employer_of",
    symmetric: false, allowed_from_party_types: ["person"], allowed_to_party_types: ["organization"],
    default_from_role: "employee", default_to_role: "employer" },
  { code: "employer_of", name: "Employer Of", inverse_code: "employee_of",
    symmetric: false, allowed_from_party_types: ["organization"], allowed_to_party_types: ["person"],
    default_from_role: "employer", default_to_role: "employee" },
  { code: "subsidiary_of", name: "Subsidiary Of", inverse_code: "parent_company_of",
    symmetric: false, allowed_from_party_types: ["organization"], allowed_to_party_types: ["organization"],
    default_from_role: "subsidiary", default_to_role: "parent_company" },
  { code: "parent_company_of", name: "Parent Company Of", inverse_code: "subsidiary_of",
    symmetric: false, allowed_from_party_types: ["organization"], allowed_to_party_types: ["organization"],
    default_from_role: "parent_company", default_to_role: "subsidiary" }
], unique_by: :code)

Ref::PartyGroupType.upsert_all([
  { code: "household", name: "Household",
    allowed_party_types: ["person"], allowed_group_roles: ["head","spouse","child","member"], hierarchical: false },
  { code: "org_unit", name: "Org Unit",
    allowed_party_types: ["organization"], allowed_group_roles: ["division","department","team"], hierarchical: true },
  { code: "corporate_family", name: "Corporate Family",
    allowed_party_types: ["organization"], allowed_group_roles: ["ultimate_parent","intermediate_parent","subsidiary","member"], hierarchical: true }
], unique_by: :code)

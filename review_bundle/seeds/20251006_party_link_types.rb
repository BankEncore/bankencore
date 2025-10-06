# db/seeds/20251006_party_link_types.rb
types = [
  # People ↔ People
  { code: "spouse_of",               symmetric: true,  inverse_code: nil,
    from: %w[person], to: %w[person],
    def_from: nil, def_to: nil },

  { code: "partner",                 symmetric: true,  inverse_code: nil,
    from: %w[person], to: %w[person] },

  { code: "same_household_as",       symmetric: true,  inverse_code: nil,
    from: %w[person], to: %w[person] },

  { code: "parent_of",               symmetric: false, inverse_code: "child_of",
    from: %w[person], to: %w[person],
    def_from: "parent", def_to: "child" },
  { code: "child_of",                symmetric: false, inverse_code: "parent_of",
    from: %w[person], to: %w[person],
    def_from: "child",  def_to: "parent" },

  { code: "guardian_of",             symmetric: false, inverse_code: "ward_of",
    from: %w[person], to: %w[person],
    def_from: "guardian", def_to: "ward" },
  { code: "ward_of",                 symmetric: false, inverse_code: "guardian_of",
    from: %w[person], to: %w[person],
    def_from: "ward", def_to: "guardian" },

  { code: "personal_representative_of", symmetric: false, inverse_code: "has_personal_representative",
    from: %w[person], to: %w[person],
    def_from: "personal_representative", def_to: "decedent" },
  { code: "has_personal_representative", symmetric: false, inverse_code: "personal_representative_of",
    from: %w[person], to: %w[person],
    def_from: "decedent", def_to: "personal_representative" },

  { code: "executor_of",             symmetric: false, inverse_code: "has_executor",
    from: %w[person], to: %w[person],
    def_from: "executor", def_to: "estate" },
  { code: "has_executor",            symmetric: false, inverse_code: "executor_of",
    from: %w[person], to: %w[person],
    def_from: "estate", def_to: "executor" },

  { code: "representative_payee_for", symmetric: false, inverse_code: "has_representative_payee",
    from: %w[person], to: %w[person],
    def_from: "rep_payee", def_to: "beneficiary" },
  { code: "has_representative_payee", symmetric: false, inverse_code: "representative_payee_for",
    from: %w[person], to: %w[person],
    def_from: "beneficiary", def_to: "rep_payee" },

  # Employment and roles
  { code: "employer_of",             symmetric: false, inverse_code: "employee_of",
    from: %w[organization person], to: %w[person],
    def_from: "employer", def_to: "employee" },
  { code: "employee_of",             symmetric: false, inverse_code: "employer_of",
    from: %w[person], to: %w[organization person],
    def_from: "employee", def_to: "employer" },

  { code: "officer_of",              symmetric: false, inverse_code: "has_officer",
    from: %w[person], to: %w[organization],
    def_from: "officer", def_to: "organization" },
  { code: "has_officer",             symmetric: false, inverse_code: "officer_of",
    from: %w[organization], to: %w[person],
    def_from: "organization", def_to: "officer" },

  { code: "director_of",             symmetric: false, inverse_code: "organization_for_director",
    from: %w[person], to: %w[organization],
    def_from: "director", def_to: "organization" },
  { code: "organization_for_director", symmetric: false, inverse_code: "director_of",
    from: %w[organization], to: %w[person],
    def_from: "organization", def_to: "director" },

  { code: "manager_of_llc",          symmetric: false, inverse_code: "has_manager",
    from: %w[person organization], to: %w[organization],
    def_from: "manager", def_to: "llc" },
  { code: "has_manager",             symmetric: false, inverse_code: "manager_of_llc",
    from: %w[organization], to: %w[person organization],
    def_from: "llc", def_to: "manager" },

  { code: "member_of_llc",           symmetric: false, inverse_code: "has_member",
    from: %w[person organization], to: %w[organization],
    def_from: "member", def_to: "llc" },
  { code: "has_member",              symmetric: false, inverse_code: "member_of_llc",
    from: %w[organization], to: %w[person organization],
    def_from: "llc", def_to: "member" },

  { code: "shareholder_of",          symmetric: false, inverse_code: "has_shareholder",
    from: %w[person organization], to: %w[organization],
    def_from: "shareholder", def_to: "issuer" },
  { code: "has_shareholder",         symmetric: false, inverse_code: "shareholder_of",
    from: %w[organization], to: %w[person organization],
    def_from: "issuer", def_to: "shareholder" },

  { code: "beneficial_owner_of",     symmetric: false, inverse_code: "has_beneficial_owner",
    from: %w[person organization], to: %w[organization],
    def_from: "ubo", def_to: "company" },
  { code: "has_beneficial_owner",    symmetric: false, inverse_code: "beneficial_owner_of",
    from: %w[organization], to: %w[person organization],
    def_from: "company", def_to: "ubo" },

  # Business relationships
  { code: "vendor_of",               symmetric: false, inverse_code: "customer_of",
    from: %w[organization], to: %w[organization person],
    def_from: "vendor", def_to: "customer" },
  { code: "customer_of",             symmetric: false, inverse_code: "vendor_of",
    from: %w[organization person], to: %w[organization],
    def_from: "customer", def_to: "vendor" },

  { code: "contractor_of",           symmetric: false, inverse_code: "client_of",
    from: %w[organization person], to: %w[organization person],
    def_from: "contractor", def_to: "client" },
  { code: "client_of",               symmetric: false, inverse_code: "contractor_of",
    from: %w[organization person], to: %w[organization person],
    def_from: "client", def_to: "contractor" },

  { code: "affiliate_of",            symmetric: true,  inverse_code: nil,
    from: %w[organization], to: %w[organization] },

  { code: "parent_org_of",           symmetric: false, inverse_code: "subsidiary_of",
    from: %w[organization], to: %w[organization],
    def_from: "parent", def_to: "subsidiary" },
  { code: "subsidiary_of",           symmetric: false, inverse_code: "parent_org_of",
    from: %w[organization], to: %w[organization],
    def_from: "subsidiary", def_to: "parent" },

  { code: "owner_of",                symmetric: false, inverse_code: "owned_by",
    from: %w[person organization], to: %w[person organization],
    def_from: "owner", def_to: "asset_holder" },
  { code: "owned_by",                symmetric: false, inverse_code: "owner_of",
    from: %w[person organization], to: %w[person organization],
    def_from: "asset_holder", def_to: "owner" },

  # Authority and representation
  { code: "attorney_for",            symmetric: false, inverse_code: "has_attorney",
    from: %w[person organization], to: %w[person organization],
    def_from: "attorney", def_to: "client" },
  { code: "has_attorney",            symmetric: false, inverse_code: "attorney_for",
    from: %w[person organization], to: %w[person organization],
    def_from: "client", def_to: "attorney" },

  { code: "attorney_in_fact_for",    symmetric: false, inverse_code: "has_attorney_in_fact",
    from: %w[person], to: %w[person organization],
    def_from: "attorney_in_fact", def_to: "principal" },
  { code: "has_attorney_in_fact",    symmetric: false, inverse_code: "attorney_in_fact_for",
    from: %w[person organization], to: %w[person],
    def_from: "principal", def_to: "attorney_in_fact" },

  { code: "agent_of",                symmetric: false, inverse_code: "principal_of",
    from: %w[person organization], to: %w[person organization],
    def_from: "agent", def_to: "principal" },
  { code: "principal_of",            symmetric: false, inverse_code: "agent_of",
    from: %w[person organization], to: %w[person organization],
    def_from: "principal", def_to: "agent" },

  { code: "guarantor_of",            symmetric: false, inverse_code: "has_guarantor",
    from: %w[person organization], to: %w[person organization],
    def_from: "guarantor", def_to: "obligor" },
  { code: "has_guarantor",           symmetric: false, inverse_code: "guarantor_of",
    from: %w[person organization], to: %w[person organization],
    def_from: "obligor", def_to: "guarantor" },

  { code: "pledgor_of",              symmetric: false, inverse_code: "has_pledgor",
    from: %w[person organization], to: %w[person organization],
    def_from: "pledgor", def_to: "secured_party" },
  { code: "has_pledgor",             symmetric: false, inverse_code: "pledgor_of",
    from: %w[person organization], to: %w[person organization],
    def_from: "secured_party", def_to: "pledgor" },

  { code: "custodian_of",            symmetric: false, inverse_code: "has_custodian",
    from: %w[organization person], to: %w[person organization],
    def_from: "custodian", def_to: "account_holder" },
  { code: "has_custodian",           symmetric: false, inverse_code: "custodian_of",
    from: %w[person organization], to: %w[organization person],
    def_from: "account_holder", def_to: "custodian" },

  # Referrals and introductions
  { code: "introduced",              symmetric: false, inverse_code: "introduced_by",
    from: %w[person organization], to: %w[person organization],
    def_from: "introducer", def_to: "introduced" },
  { code: "introduced_by",           symmetric: false, inverse_code: "introduced",
    from: %w[person organization], to: %w[person organization],
    def_from: "introduced", def_to: "introducer" },

  { code: "reference_for",           symmetric: false, inverse_code: "referred_by",
    from: %w[person organization], to: %w[person organization],
    def_from: "referee", def_to: "subject" },
  { code: "referred_by",             symmetric: false, inverse_code: "reference_for",
    from: %w[person organization], to: %w[person organization],
    def_from: "subject", def_to: "referee" }
]

types.each do |t|
  rec = Ref::PartyLinkType.find_or_initialize_by(code: t[:code])
  rec.name ||= t[:code].humanize
  rec.symmetric     = !!t[:symmetric]
  rec.inverse_code  = t[:inverse_code]
  rec.allowed_from_party_types = t[:from]
  rec.allowed_to_party_types   = t[:to]
  rec.default_from_role = t[:def_from]
  rec.default_to_role   = t[:def_to]
  rec.save!
end

# Sanity: symmetric types must have NULL inverse_code; non-symmetric must have one.
Ref::PartyLinkType.where(symmetric: true).update_all(inverse_code: nil)
Ref::PartyLinkType.where(symmetric: false).where(inverse_code: nil).find_each do |r|
  Rails.logger.warn "Missing inverse_code for #{r.code}"
end

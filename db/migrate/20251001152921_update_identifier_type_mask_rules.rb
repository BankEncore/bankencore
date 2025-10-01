class UpdateIdentifierTypeMaskRules < ActiveRecord::Migration[7.2]
  def up
    Ref::IdentifierType.where(code: 'ssn')
      .update_all(mask_rule: 'ssn', sort_order: 100)

    Ref::IdentifierType.where(code: 'ein')
      .update_all(mask_rule: 'ein', sort_order: 120)

    Ref::IdentifierType.where(code: %w[tin itin])
      .update_all(mask_rule: 'ssn', sort_order: 140)

    Ref::IdentifierType.where(code: 'passport')
      .update_all(mask_rule: 'first1_last4', sort_order: 200,
                  require_issuer_country: true)

    Ref::IdentifierType.where(code: 'dl')
      .update_all(mask_rule: 'first1_last4', sort_order: 220,
                  require_issuer_country: true, require_issuer_region: true)
  end

  def down
    Ref::IdentifierType.where(code: %w[ssn ein tin itin passport dl])
      .update_all(mask_rule: nil, sort_order: nil,
                  require_issuer_country: false, require_issuer_region: false)
  end
end

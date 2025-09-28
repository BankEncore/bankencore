# app/models/concerns/single_primary.rb
module SinglePrimary
  extend ActiveSupport::Concern

  included do
    before_save :enforce_single_primary
    validates :is_primary, inclusion: { in: [ true, false ] }
  end

  private

  def enforce_single_primary
    return unless is_primary_changed? && is_primary? && party_id.present?
    self.class.where(party_id: party_id).where.not(id: id).update_all(is_primary: false)
  end
end

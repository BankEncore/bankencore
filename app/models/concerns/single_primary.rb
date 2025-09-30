# app/models/concerns/single_primary.rb
module SinglePrimary
  extend ActiveSupport::Concern

  included do
    # optional: default false so nil never sneaks through
    attribute :is_primary, :boolean, default: false

    # Demote siblings if this record is primary.
    around_save :enforce_single_primary
  end

  private

  def enforce_single_primary
    if is_primary && party_id.present?
      self.class.transaction do
        # Demote others for the same party
        self.class.where(party_id: party_id).where.not(id: id).update_all(is_primary: false)
        yield
      end
    else
      yield
    end
  end
end

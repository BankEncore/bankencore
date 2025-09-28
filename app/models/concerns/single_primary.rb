# app/models/concerns/single_primary.rb
module SinglePrimary
  extend ActiveSupport::Concern
  included { before_save :enforce_single_primary }

  private
  def enforce_single_primary
    return unless will_save_change_to_is_primary? && is_primary
    self.class.where(party_id: party_id).where.not(id: id).update_all(is_primary: false)
  end
end

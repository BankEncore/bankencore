# app/models/party/screening.rb
module Party
  class Screening < ApplicationRecord
    self.table_name = "party_screenings"

    enum :vendor, { manual: 0 }              # extend later
    enum :kind, { sanctions: 0, pep: 1, watchlist: 2, adverse_media: 3, idv: 4 }
    enum :status, { pending: 0, matched: 1, clear: 2, needs_review: 3, rejected: 4, error: 5 }

    belongs_to :party, class_name: "Party::Party", inverse_of: :screenings

    validates :kind, :status, :vendor, presence: true

    scope :open, -> { where(status: [ :pending, :needs_review ]) }

    after_commit :touch_party_cache

    def expired?
      expires_at.present? && expires_at < Time.current
    end

    private

    def touch_party_cache
      party.update_columns(last_screened_at: completed_at || requested_at || Time.current)
    end
  end
end

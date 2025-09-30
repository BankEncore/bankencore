# config/initializers/risk_scoring.rb
# Loads config/risk_scoring.yml if present and merges over sane defaults.
# Never crashes boot or db:prepare when the file is missing.

module RiskScoring
  DEFAULT = {
    weights: {
      sanctions: 0.50, pep: 0.20, watchlist: 0.15, adverse_media: 0.10, idv: 0.05
    },
    thresholds: { clear_max: 39, review_min: 40, match_min: 70 },
    decay_half_life_hours: { sanctions: 720, pep: 720, watchlist: 168, adverse_media: 168, idv: 12 },
    categories: { clear: 0, possible: 60, match: 85, strong_match: 95 },
    adjustments: { exact_name_dob_country: 10, id_last4_match: 15, fuzzy_name_only: -15 }
  }.freeze

  def self.load!
    raw = begin
      # returns {} if file missing or env key absent
      Rails.application.config_for(:risk_scoring)
    rescue StandardError
      {}
    end

    merged = DEFAULT.deep_merge(raw.presence || {})
    merged.deep_symbolize_keys.freeze
  end
end

RISK_SCORING = RiskScoring.load!

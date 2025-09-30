# app/services/party_risk_refresher.rb
class PartyRiskRefresher
  def self.run(party)
    weights = RISK_SCORING[:weights].symbolize_keys
    latest = party.screenings.group_by(&:kind).transform_values { |xs| xs.compact.max_by(&:completed_at) }
    score = latest.sum do |kind, s|
      next 0 unless s&.normalized_score
      s.normalized_score.to_f * (weights[kind.to_sym] || 0)
    end.round
    band = case score
    when 0..39 then 0
    when 40..69 then 1
    else 2
    end
    party.update_columns(party_risk_score: score, risk_band: band, updated_at: Time.current)
  end
end

# app/services/screening_scorer.rb
class ScreeningScorer
  def initialize(screening) = (@s = screening)

  def run
    @s.normalized_score = normalized.clamp(0, 100)
    @s.match_strength ||= inferred_match_strength
    @s
  end

  private

  def normalized
    base = vendor_number || categorical || 0
    base + adjustment
  end

  def vendor_number
    n = @s.vendor_score
    return unless n.is_a?(Numeric)
    [ [ n.to_f, 0 ].max, 100 ].min
  end

  def categorical
    cat = @s.vendor_payload.is_a?(Hash) ? @s.vendor_payload["category"] : nil
    map = RISK_SCORING.dig(:categories) || {}
    map[cat.to_s]&.to_i
  end

  def adjustment
    adj = RISK_SCORING[:adjustments]
    return adj[:id_last4_match].to_i if id_last4_match?
    return adj[:exact_name_dob_country].to_i if exact_triplet?
    return adj[:fuzzy_name_only].to_i if fuzzy_only?
    0
  end

  def id_last4_match?
    q = @s.query_identifier_last4.to_s
    p = Array(@s.vendor_payload&.dig("id_last4s")).map(&:to_s)
    q.present? && p.include?(q)
  end

  def exact_triplet?
    v = @s.vendor_payload || {}
    [ @s.query_name,  @s.query_dob,  @s.query_country ].all?(&:present?) &&
    v["name_exact"] == true && v["dob_exact"] == true && v["country"] == @s.query_country
  end

  def fuzzy_only?
    v = @s.vendor_payload || {}
    v["name_fuzzy"] == true && !v["dob_exact"] && !id_last4_match?
  end
end

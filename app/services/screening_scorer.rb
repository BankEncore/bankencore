class ScreeningScorer
  def initialize(screening) = @s = screening
  def normalize
    n = case @s.vendor_score
    when Numeric then [ [ @s.vendor_score.to_f, 0 ].max, 100 ].min
    else categorical(@s.vendor_payload&.dig("category"))
    end
    n += adjustment
    @s.normalized_score = n.clamp(0, 100)
  end

  def categorical(cat)
    map = Rails.application.config_for("risk/scoring")["categories"]["categorical_map"]
    map[cat.to_s] || 0
  end

  def adjustment
    cfg = Rails.application.config_for("risk/scoring")["adjustments"]
    return cfg["id_last4_match"]    if id_last4_match?
    return cfg["exact_name_dob_country"] if exact_match_triplet?
    return cfg["fuzzy_name_only"]   if fuzzy_only?
    0
  end
end

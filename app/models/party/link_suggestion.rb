# app/models/party/link_suggestion.rb
class Party::LinkSuggestion < ApplicationRecord
  self.table_name = "party_link_suggestions"

  belongs_to :source_party, class_name: "Party::Party"
  belongs_to :target_party, class_name: "Party::Party"
  belongs_to :reviewed_by,  class_name: "Internal::User", optional: true

  validates :suggested_link_type_code, presence: true
  validates :confidence_score, numericality: { in: 0.0..1.0 }

  before_validation :coerce_evidence_to_json
  validate :validate_evidence_json
  validate :type_compatibility

  # inline replacements for no_self_links + not_already_linked
  validate do
    if source_party_id.present? && target_party_id.present? && source_party_id == target_party_id
      errors.add(:base, "self-link")
    end

    if source_party_id.present? && target_party_id.present? && suggested_link_type_code.present?
      if Party::Link.exists?(source_party_id: source_party_id,
                             target_party_id: target_party_id,
                             party_link_type_code: suggested_link_type_code)
        errors.add(:base, "already linked")
      end
    end
  end

  scope :pending, -> { where(reviewed_flag: false) }

  def type_compatibility
    return unless source_party_id.present? && target_party_id.present? && suggested_link_type_code.present?

    lt = Ref::PartyLinkType.find_by(code: suggested_link_type_code)
    return errors.add(:suggested_link_type_code, "unknown") unless lt

    # Normalize various schema shapes into arrays of strings
    parse = ->(v) do
      if v.is_a?(String) && v.strip.start_with?("[")
        begin
          JSON.parse(v).map!(&:to_s)
        rescue JSON::ParserError
          [ v.to_s ]
        end
      else
        Array(v).map!(&:to_s)
      end
    end

    from_raw = if lt.respond_to?(:allowed_from_party_types) then lt.allowed_from_party_types
    elsif lt.respond_to?(:source_allowed_party_types) then lt.source_allowed_party_types
    elsif lt.respond_to?(:from_party_type) then lt.from_party_type
    end

    to_raw   = if lt.respond_to?(:allowed_to_party_types) then lt.allowed_to_party_types
    elsif lt.respond_to?(:target_allowed_party_types) then lt.target_allowed_party_types
    elsif lt.respond_to?(:to_party_type) then lt.to_party_type
    end

    from_allowed = parse.call(from_raw)
    to_allowed   = parse.call(to_raw)

    s_type = (defined?(source_party) && source_party&.party_type) ||
             Party::Party.where(id: source_party_id).pick(:party_type)
    t_type = (defined?(target_party) && target_party&.party_type) ||
             Party::Party.where(id: target_party_id).pick(:party_type)

    unless from_allowed.include?(s_type.to_s) && to_allowed.include?(t_type.to_s)
      errors.add(:base, "party types incompatible for #{suggested_link_type_code}")
    end
  end

  private

  def coerce_evidence_to_json
    case evidence
    when nil, ""
      self.evidence = "{}"
    when Hash
      self.evidence = JSON.generate(evidence)
    when String
      begin
        # Valid JSON? normalize it
        parsed = JSON.parse(evidence)
        self.evidence = JSON.generate(parsed)
      rescue JSON::ParserError
        # Not JSON — wrap it so it passes CHECK(JSON_VALID(...))
        self.evidence = JSON.generate({ "raw" => evidence.to_s })
      end
    else
      # Anything else — wrap as string
      self.evidence = JSON.generate({ "raw" => evidence.to_s })
    end
  end

  # keep this if you want to enforce an object (not array/number) shape:
  validate :validate_evidence_json
  def validate_evidence_json
    parsed = JSON.parse(evidence.presence || "{}")
    errors.add(:evidence, "must be a JSON object") unless parsed.is_a?(Hash)
  rescue JSON::ParserError
    # Should never happen after coercion, but guard anyway:
    errors.add(:evidence, "must be valid JSON")
  end

  # handy helper if callers need a Hash
  def evidence_hash
    JSON.parse(evidence.presence || "{}")
  rescue JSON::ParserError
    {}
  end
end

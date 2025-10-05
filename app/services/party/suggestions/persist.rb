# app/services/party/suggestions/persist.rb
class Party::Suggestions::Persist
  def self.links!(results)
    results.each do |r|
      Party::LinkSuggestion.find_or_create_by!(
        source_party_id: r.source_party_id,
        target_party_id: r.target_party_id,
        suggested_link_type_code: r.suggested_link_type_code,
        detected_by: r.detected_by
      ) do |rec|
        rec.confidence_score = r.confidence
        rec.evidence = r.evidence
      end
    end
  end

  def self.groups!(results)
    results.each do |r|
      Party::GroupSuggestion.create!(
        group_type_code: r.group_type_code,
        name: r.name,
        members: r.members,
        confidence_score: r.confidence,
        detected_by: r.detected_by,
        evidence: r.evidence
      )
    rescue ActiveRecord::RecordInvalid
      next
    end
  end
end

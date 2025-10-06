# app/helpers/party/links_helper.rb
module Party::LinksHelper
  def links_list(viewer, code:)
    rel = ::Party::Link.of_type(code)
    t   = Ref::PartyLinkType.find_by(code: code)

    if t&.symmetric == 1
      # show one row per symmetric relation; normalize by smaller id
      rel = rel.where("(source_party_id = :id AND source_party_id < target_party_id)
                       OR (target_party_id = :id AND target_party_id < source_party_id)", id: viewer.id)
    else
      # directional: only show outbound from the viewer
      rel = rel.where(source_party_id: viewer.id)
    end

    rel.includes(:source_party, :target_party)
  end
end

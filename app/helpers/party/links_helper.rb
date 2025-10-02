# app/helpers/party/links_helper.rb
module Party::LinksHelper
  def rel_badge(link, viewer:)
    other = link.source_party_id == viewer.id ? link.target_party : link.source_party
    content_tag(:span, Ref::PartyLinkType.find(link.party_link_type_code).name, class: "badge badge-ghost") +
      " ".html_safe +
      link_to(other.display_name, party_party_path(other))
  end

  def links_list(viewer, code:)
    Party::Link.involving(viewer.id).of_type(code).includes(:source_party, :target_party)
  end
end

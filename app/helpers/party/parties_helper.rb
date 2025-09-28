# app/helpers/party/parties_helper.rb
module Party::PartiesHelper
  def party_type_icon(party, size: 20)
    t = party.party_type.to_s.downcase
    cls = "inline-block align-middle text-base-content" # visible color
    case t
    when "person"
      %Q(
        <svg class="#{cls}" width="#{size}" height="#{size}" viewBox="0 0 24 24" role="img" aria-label="Person">
          <title>Person</title>
          <path fill="currentColor" d="M12 12a5 5 0 1 0-5-5a5 5 0 0 0 5 5Zm0 2c-4.418 0-8 2.239-8 5v1h16v-1c0-2.761-3.582-5-8-5z"/>
        </svg>
      ).html_safe
    when "organization"
      %Q(
        <svg class="#{cls}" width="#{size}" height="#{size}" viewBox="0 0 24 24"
            role="img" aria-label="Organization"
            fill="none" stroke="currentColor" stroke-width="2"
            stroke-linecap="round" stroke-linejoin="round">
          <title>Organization</title>
          <path stroke="none" d="M0 0h24v24H0z" fill="none"/>
          <path d="M3 7m0 2a2 2 0 0 1 2 -2h14a2 2 0 0 1 2 2v9a2 2 0 0 1 -2 2h-14a2 2 0 0 1 -2 -2z"/>
          <path d="M8 7v-2a2 2 0 0 1 2 -2h4a2 2 0 0 1 2 2v2"/>
          <path d="M12 12l0 .01"/>
          <path d="M3 13a20 20 0 0 0 18 0"/>
        </svg>
      ).html_safe
    else
      %Q(
        <svg class="#{cls}" width="#{size}" height="#{size}" viewBox="0 0 24 24" role="img" aria-label="Unknown">
          <title>Unknown</title>
          <path fill="currentColor" d="M12 2a10 10 0 1 0 10 10A10.011 10.011 0 0 0 12 2Zm1 16h-2v-2h2Zm1.07-7.75l-.9.92A1.49 1.49 0 0 0 12.5 13h-1v-1a2 2 0 0 1 .59-1.42l1.24-1.26a1.5 1.5 0 1 0-2.53-1.06H9.5a3.5 3.5 0 1 1 6.06 2.03Z"/>
        </svg>
      ).html_safe
    end
  end

    def sort_link(label, key)
        current = params[:sort].to_s
        dir     = params[:dir].to_s
        nextdir = (current == key.to_s && dir == "asc") ? "desc" : "asc"
        arrow   = current == key.to_s ? (dir == "asc" ? "▲" : "▼") : ""

        link_to "#{label} #{arrow}".strip,
                url_for(params.permit!.to_h.merge(sort: key, dir: nextdir, only_path: true)),
                class: "link link-hover"
    end

      # Returns [["Pennsylvania","PA"], ...] for a given country_code or []
      def regions_for(country_code)
        return [] if country_code.blank?
        Ref::Region.where(country_code: country_code)
                  .order(:name)
                  .pluck(:name, :code)
      end
end

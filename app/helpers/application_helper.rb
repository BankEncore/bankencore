module ApplicationHelper
    def nav_link_to_route(name, helper, **opts)
        h = Rails.application.routes.url_helpers
        path = h.respond_to?(helper) ? h.public_send(helper) : "#"
        nav_link_to(name, path, **opts)
    end
    def ref_label(ref)
        return "" if ref.blank?
        val = (ref.respond_to?(:name) && ref.name.presence) ||
            (ref.respond_to?(:key)  && ref.key.presence)  ||
            (ref.respond_to?(:code) && ref.code.presence)
        (val || ref).to_s.titleize
    end
end

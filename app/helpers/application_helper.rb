module ApplicationHelper
    def nav_link_to_route(name, helper, **opts)
        h = Rails.application.routes.url_helpers
        path = h.respond_to?(helper) ? h.public_send(helper) : "#"
        nav_link_to(name, path, **opts)
    end

end

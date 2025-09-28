module NavigationHelper
  def nav_link_to(name, path, **opts)
    active = current_page?(path)
    classes = [ "link", "px-2", ("font-semibold" if active), ("text-primary" if active) ]
      .compact.join(" ")
    link_to name, path, { class: classes }.merge(opts)
  end
end

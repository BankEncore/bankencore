module PhoneHelper
  def phone_country_options
    if defined?(ISO3166::Country)
      ISO3166::Country.all
        .select(&:alpha2)
        .map { |c| ["#{c.emoji_flag} #{c.translations[I18n.locale.to_s] || c.name}", c.alpha2] }
        .sort_by(&:first)
    else
      # Minimal fallback
      [["🇺🇸 United States", "US"], ["🇨🇦 Canada", "CA"], ["🇬🇧 United Kingdom", "GB"]]
    end
  end
end
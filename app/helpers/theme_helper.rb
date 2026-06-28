module ThemeHelper
  CSS_THEME_MAP = {
    "selenized_light" => "solunized-light",
    "white" => "solunized-white",
    "selenized_dark" => "solunized-dark",
    "black" => "solunized-black"
  }.freeze

  def theme_attributes
    return {} unless Current.user

    color_scheme = Current.user.color_scheme
    light = Current.user.light_theme
    dark = Current.user.dark_theme

    attrs = {
      "data-color-scheme": color_scheme,
      "data-light-theme": light,
      "data-dark-theme": dark
    }

    case color_scheme
    when "light"
      attrs[:"data-theme"] = CSS_THEME_MAP[light]
    when "dark"
      attrs[:"data-theme"] = CSS_THEME_MAP[dark]
    end

    attrs
  end

  def saved_theme_attributes
    theme_attributes.except(:"data-theme")
  end
end

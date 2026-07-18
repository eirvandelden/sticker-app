Appkit.configure do |config|
  config.app_name    = -> { I18n.t("app.title") }
  config.brand_color = "#c51f23" # mvpa's --color-red, computed to sRGB
  config.user_scope  = -> { User.active }

  # Sticker App only ships icon.svg/icon-192.png/icon.png (no 512/maskable
  # variants) — the engine's defaults would 404 for files this app never had.
  config.icons = %w[/icon.svg /icon-192.png /icon.png]

  # Sticker App has no seed/rake bootstrap for the first account; the first
  # user gets :admin (not the engine default :administrator) so they get
  # both the admin namespace and parent access (ensure_parent allows admins).
  config.first_run = ->(user_params) { User.create!(user_params.merge(role: :admin)) }
end

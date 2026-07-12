json.name t("app.title")
json.short_name t("app.title")

json.icons [
  { src: "/icon-192.png", type: "image/png", sizes: "192x192" },
  { src: "/icon.png", type: "image/png", sizes: "512x512" },
  { src: "/icon.png", type: "image/png", sizes: "512x512", purpose: "maskable" }
]

json.start_url "/"
json.display "standalone"
json.scope "/"
json.theme_color "#c51f23"
json.background_color "#f5f9fa"

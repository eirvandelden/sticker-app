# Builds the signed-in user's menu map once per request and gives it to the views.
# @rbs module-self: ActionController::Base
# @rbs module-self: _RbsRailsPathHelpers
module MenuMap
  # @type const Appkit::Menu: untyped
  # @type const Appkit::Menu::Hub: untyped
  # @type const Appkit::Menu::Page: untyped
  # @type const Current: untyped
  extend ActiveSupport::Concern

  included do
    # @type self: singleton(ActionController::Base)
    helper_method :menu
  end

  private

  # Places this request in the menu map: its hubs, the current hub and page, the origin and the back link.
  # @rbs () -> untyped
  def menu
    @menu ||= Appkit::Menu.new(hubs: menu_hubs, controller_path: controller_path, params: request.parameters)
  end

  # Dashboard and Account for a child; Kinderen, Instellingen, Beheer (admin only) and Account otherwise.
  # @rbs () -> Array[untyped]
  def menu_hubs
    return [ dashboard_hub, account_hub ] if Current.user.child?

    [ children_hub, settings_hub, (admin_hub if Current.user.admin?), account_hub ].compact
  end

  # @rbs () -> untyped
  def children_hub
    Appkit::Menu::Hub.new(
      key: :children, label: t("menu.hubs.children"), emoji: "👨‍👧", path: parent_children_path,
      landing: { "controller" => "parent/children", "action" => "index" },
      pages: [ Appkit::Menu::Page.new(key: :overview, label: t("menu.pages.overview"), path: parent_children_path,
        controllers: CHILDREN_CONTROLLERS) ]
    )
  end

  # @rbs () -> untyped
  def settings_hub
    Appkit::Menu::Hub.new(
      key: :settings, label: t("menu.hubs.settings"), emoji: "⚙️", path: parent_settings_path,
      landing: { "controller" => "parent/settings" },
      pages: [ Appkit::Menu::Page.new(key: :child_settings, label: t("menu.pages.child_settings"),
        path: parent_settings_path, controllers: [ "parent/settings" ]) ]
    )
  end

  # @rbs () -> untyped
  def admin_hub
    Appkit::Menu::Hub.new(
      key: :admin, label: t("menu.hubs.admin"), emoji: "🛠️", path: admin_root_path,
      landing: { "controller" => "admin/dashboard" },
      pages: [ Appkit::Menu::Page.new(key: :users, label: t("admin.nav.users"), path: admin_users_path,
        controllers: [ "admin/users" ]) ]
    )
  end

  # @rbs () -> untyped
  def dashboard_hub
    Appkit::Menu::Hub.new(
      key: :dashboard, label: t("menu.hubs.dashboard"), emoji: "🏠", path: child_dashboard_path,
      landing: { "controller" => "child/dashboard" }
    )
  end

  # @rbs () -> untyped
  def account_hub
    Appkit::Menu::Hub.new(
      key: :account, label: t("menu.hubs.account"), emoji: "👤", path: account_path,
      landing: { "controller" => "accounts" }, pages: account_pages
    )
  end

  # Voorkeuren, Profiel and, last, the Uitloggen submit page.
  # @rbs () -> Array[untyped]
  def account_pages
    [
      Appkit::Menu::Page.new(key: :preferences, label: t("appkit.navigation.preferences"),
        path: edit_preferences_path, controllers: [ "appkit/preferences" ]),
      Appkit::Menu::Page.new(key: :profile, label: t("menu.pages.profile"),
        path: user_profile_path(Current.user), controllers: [ "users/profiles" ]),
      Appkit::Menu::Page.new(key: :sign_out, label: t("appkit.navigation.logout"), path: session_path,
        controllers: [], verb: :delete)
    ]
  end

  CHILDREN_CONTROLLERS = %w[
    parent/children parent/stickers parent/penalties parent/rewards parent/child_profiles
    parent/children_avatar parent/sticker_card_goals parent/allowances parent/allowance_payments
  ].freeze
  private_constant :CHILDREN_CONTROLLERS
end

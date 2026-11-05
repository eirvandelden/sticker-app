require "application_system_test_case"

# The parent dashboard on an iPhone 12 mini home-screen app: 375 CSS px wide, and
# 728 CSS px tall once the status bar and the home indicator are taken off 812.
class ParentDashboardFitTest < ApplicationSystemTestCase
  IPHONE_12_MINI = { width: 375, height: 728, deviceScaleFactor: 3, mobile: true }.freeze

  LONG_NAMES = {
    user: "Alexandra Wilhelmina van Dijke",
    user_two: "Bartholomeus Cornelis de Vries",
    user_three: "Charlotte Josephina Vermeulens"
  }.freeze

  setup do
    @emulated_sessions = []
  end

  teardown do
    @emulated_sessions.uniq.each do |name|
      Capybara.using_session(name) do
        page.driver.browser.execute_cdp("Emulation.clearDeviceMetricsOverride")
      end
    end
    Capybara.reset_sessions!
  end

  test "three children with no card ready fit above the tab bar on an iPhone 12 mini" do
    give_bob_a_fresh_card

    sign_in users(:parent)
    visit_on_iphone_12_mini parent_children_path

    children.each { |child| assert_dashboard_row child, mark_rewarded: false }
    assert_rows_fit_above_tab_bar
  end

  test "three children with a card ready each fit above the tab bar on an iPhone 12 mini" do
    children.each { |child| make_card_ready child }

    sign_in users(:parent)
    visit_on_iphone_12_mini parent_children_path

    children.each { |child| assert_dashboard_row child, mark_rewarded: true }
    assert_rows_fit_above_tab_bar
  end

  test "long names and Dutch labels still fit above the tab bar" do
    LONG_NAMES.each { |fixture, name| users(fixture).update!(name: name) }
    children.each { |child| make_card_ready child }

    sign_in dutch_parent
    visit_on_iphone_12_mini parent_children_path

    children.each { |child| assert_dashboard_row child, mark_rewarded: true, locale: :nl }
    assert_rows_fit_above_tab_bar
  end

  test "mark rewarded on the dashboard gives the card and removes the button" do
    charlie = child_profiles(:three)
    ready_card = make_card_ready charlie

    sign_in users(:parent)
    visit parent_children_path
    connect_turbo_cable_stream_sources

    within_dashboard_row(charlie) { click_button I18n.t("parent.actions.mark_rewarded") }

    within_dashboard_row(charlie) { assert_no_button I18n.t("parent.actions.mark_rewarded"), wait: 10 }
    assert_predicate ready_card.reload, :reward_given?
  end

  test "mark rewarded stays on the dashboard while a second card is ready" do
    charlie = child_profiles(:three)
    oldest_card = make_card_ready charlie
    newest_card = make_card_ready charlie

    sign_in users(:parent)
    visit parent_children_path
    connect_turbo_cable_stream_sources

    within_dashboard_row(charlie) { click_button I18n.t("parent.actions.mark_rewarded") }

    within_dashboard_row(charlie) do
      assert_selector "##{dom_id(charlie, :reward_badge)}",
                      text: I18n.t("parent.dashboard.rewardable_cards", count: 1), wait: 10
      assert_button I18n.t("parent.actions.mark_rewarded")
    end
    assert_predicate oldest_card.reload, :reward_given?
    assert_not newest_card.reload.reward_given?
  end

  test "mark rewarded appears live when a card completes and the rows still fit" do
    bob = child_profiles(:two)
    give_bob_a_fresh_card

    sign_in users(:parent)
    visit_on_iphone_12_mini parent_children_path
    connect_turbo_cable_stream_sources

    within_dashboard_row(bob) { assert_no_button I18n.t("parent.actions.mark_rewarded") }

    make_card_ready bob

    within_dashboard_row(bob) { assert_button I18n.t("parent.actions.mark_rewarded"), wait: 10 }
    assert_rows_fit_above_tab_bar
  end

  test "tab bar tabs share one row inside the viewport for parent, admin and child" do
    { users(:parent) => parent_children_path,
      users(:admin) => parent_children_path,
      users(:user) => child_dashboard_path }.each do |user, path|
      sign_in user
      visit_on_iphone_12_mini path

      assert_admin_tabs if user.admin?

      assert_tabs_in_one_row_inside_viewport user
      Capybara.reset_session!
    end
  end

  private

  def within_dashboard_row(child, &)
    within("##{dom_id(child, :dashboard_row)}", &)
  end

  def children
    child_profiles(:one, :two, :three)
  end

  def dutch_parent
    User.create!(name: "Dutch Parent", email: "dutch-parent@example.com", password: "password",
                 role: :parent, locale: "nl")
  end

  # Bob's fixtures leave a card ready to reward; give it, and start Bob on an empty card.
  def give_bob_a_fresh_card
    sticker_cards(:completed_unrewarded).update!(reward_given: true)
    child_profiles(:two).sticker_cards.create!
  end

  # Fills the active card when it is not complete yet, and returns the card that is ready.
  def make_card_ready(profile)
    card = profile.active_sticker_card
    (card.required_stickers - card.positive_count).times { card.stickers.create!(kind: :positive) }
    card
  end

  def sign_in(user)
    visit session_transfer_path(user.transfer_id)
    # The transfer page auto-submits via a Stimulus controller; give it more time
    # than Capybara's default before asserting the landed page.
    assert_current_path(user.child? ? child_dashboard_path : parent_children_path, wait: 10)
  end

  def visit_on_iphone_12_mini(path)
    page.driver.browser.execute_cdp("Emulation.setDeviceMetricsOverride", **IPHONE_12_MINI)
    @emulated_sessions << Capybara.session_name
    visit path
  end

  def assert_dashboard_row(child, mark_rewarded:, locale: :en)
    within_dashboard_row(child) do
      assert_selector "h2", text: child.user.reload.name
      assert_selector "progress"
      assert_button I18n.t("parent.actions.give_sticker", locale: locale)
      assert_button I18n.t("parent.actions.give_penalty", locale: locale)
      assert_mark_rewarded_button(mark_rewarded, locale)
    end
  end

  def assert_mark_rewarded_button(present, locale)
    label = I18n.t("parent.actions.mark_rewarded", locale: locale)
    present ? assert_button(label) : assert_no_button(label)
  end

  def assert_rows_fit_above_tab_bar
    layout = page.evaluate_script(<<~JS)
      (() => {
        window.scrollTo(0, 0);
        const parts = document.querySelectorAll('article[data-controller="confetti"] :is(h2, progress, button)');
        return {
          scrollY: window.scrollY,
          tabBarTop: document.querySelector("body > header").getBoundingClientRect().top,
          lowestBottom: Math.max(...Array.from(parts, (part) => part.getBoundingClientRect().bottom))
        };
      })()
    JS

    assert_equal 0, layout["scrollY"]
    assert_operator layout["tabBarTop"], :<, IPHONE_12_MINI[:height], "Expected the tab bar at the bottom of the screen"
    assert_operator layout["lowestBottom"], :<=, layout["tabBarTop"],
                    "Expected every row part to end above the tab bar at scroll position 0"
  end

  def assert_admin_tabs
    within("body > header nav") do
      assert_link I18n.t("admin.nav.overview")
      assert_link I18n.t("admin.nav.users")
    end
  end

  def assert_tabs_in_one_row_inside_viewport(user)
    tabs = page.evaluate_script(<<~JS)
      Array.from(document.querySelectorAll("body > header nav > ul > li"), (tab) => {
        const box = tab.querySelector("a, button").getBoundingClientRect();
        return { label: tab.textContent.trim(), top: box.top, bottom: box.bottom, left: box.left, right: box.right };
      })
    JS

    row_top = tabs.first&.fetch("top")

    assert_not_empty tabs, "Expected tabs in the tab bar for #{user.name}"
    tabs.each { |tab| assert_in_delta row_top, tab["top"], 1, "Expected one row of tabs: #{user.name} #{tab}" }
    tabs.each { |tab| assert_tab_inside_viewport tab, user }
  end

  def assert_tab_inside_viewport(tab, user)
    message = "Expected the whole tab inside the viewport: #{user.name} #{tab}"

    assert_operator tab["left"], :>=, 0, message
    assert_operator tab["right"], :<=, IPHONE_12_MINI[:width], message
    assert_operator tab["bottom"], :<=, IPHONE_12_MINI[:height], message
  end
end

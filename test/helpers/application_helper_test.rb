require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "record_back_link uses the menu's back link when there is an origin" do
    @menu = menu_for("id" => "1", "from" => "things.all")

    link = record_back_link("/things")

    assert_equal "All", link.label
    assert_equal "/things?from=things.all", link.path
  end

  test "record_back_link links the fallback, labelled with the current hub, when the menu has none" do
    @menu = menu_for("action" => "update")

    link = record_back_link("/things")

    assert_equal "Things", link.label
    assert_equal "/things", link.path
  end

  private

  attr_reader :menu

  def menu_for(params)
    page = Appkit::Menu::Page.new(key: :all, label: "All", path: "/things", controllers: [ "things" ])
    hub = Appkit::Menu::Hub.new(key: :things, label: "Things", emoji: "📦", path: "/things",
      landing: { "controller" => "things", "action" => "index" }, pages: [ page ])
    Appkit::Menu.new(hubs: [ hub ], controller_path: "things", params: params)
  end
end

require "test_helper"

class Parent::ChildEditSectionsTest < ActionDispatch::IntegrationTest
  setup do
    @parent = users(:parent)
    @child = child_profiles(:one)
  end

  test "each child edit form sits in a section whose first child is its heading" do
    sign_in_as @parent

    get edit_parent_child_path(@child)

    assert_select "main > article > section", count: 5
    assert_select "main > article > section > h2:first-child", count: 5
    assert_select "main > article > section:nth-of-type(1) > h2:first-child", text: "Name"
    assert_select "main > article > section:nth-of-type(2) > h2:first-child", text: "Avatar"
    assert_select "main > article > section:nth-of-type(3) > h2:first-child", text: "Goals"
    assert_select "main > article > section:nth-of-type(4) > h2:first-child", text: "Zakgeld"
    assert_select "main > article > section:nth-of-type(5) > h2:first-child", text: "Kleedgeld"
    assert_select "main > article > section > form:has(> footer)", count: 5
  end

  test "headings read in English, Dutch and Italian" do
    { en: %w[Name Avatar Goals], nl: %w[Naam Avatar Doelen], it: %w[Nome Avatar Obiettivi] }.each do |locale, headings|
      @parent.update!(locale: locale)
      reset!
      sign_in_as @parent

      get edit_parent_child_path(@child)

      headings.each_with_index do |heading, index|
        assert_select "main > article > section:nth-of-type(#{index + 1}) > h2:first-child", text: heading
      end
      assert_select "main > article > section:nth-of-type(4) > h2", text: "Zakgeld"
      assert_select "main > article > section:nth-of-type(5) > h2", text: "Kleedgeld"
    end
  end
end

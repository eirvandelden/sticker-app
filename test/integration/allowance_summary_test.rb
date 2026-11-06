require "test_helper"

class AllowanceSummaryTest < ActionDispatch::IntegrationTest
  # Measured on the markup before the shared partial: child show and child dashboard.
  BASELINE_ALLOWANCE_QUERIES = 3

  setup do
    @parent = users(:parent)
    @child = child_profiles(:one)
  end

  test "parent card lists allowances as dt and dd with mark given" do
    sign_in_as @parent

    get parent_child_path(@child)

    assert_select "section##{dom_id(@child, :parent_card)} dl"
    assert_allowance_detail "Pocket money", /1 payment still owed/
    assert_allowance_detail "Clothing allowance", /Up to date/
    assert_select "dl > dt:first-of-type + dd form[action=?]", parent_child_allowance_payments_path(@child), count: 1
    assert_select "dl > dt:last-of-type + dd form", count: 0
  end

  test "child dashboard lists allowances as dt and dd without mark given" do
    sign_in_as @child.user

    get child_dashboard_path

    assert_allowance_detail "Pocket money", /1 payment still owed/
    assert_allowance_detail "Clothing allowance", /Up to date/
    assert_select "dl form", count: 0
  end

  test "renders nothing without allowances" do
    sign_in_as users(:user_two)

    get child_dashboard_path

    assert_select "dl", count: 0
  end

  test "shows mark given only with a payments path and an owed period" do
    sign_in_as @parent

    get parent_child_path(child_profiles(:two))

    assert_select "dl", count: 0

    get parent_child_path(@child)

    assert_select "dl > dd form", count: 1
  end

  test "child show runs the same allowance queries as before" do
    sign_in_as @parent

    queries = allowance_queries { get parent_child_path(@child) }

    assert_operator queries.count, :<=, BASELINE_ALLOWANCE_QUERIES, queries.join("\n")
  end

  test "child dashboard runs the same allowance queries as before" do
    sign_in_as @child.user

    queries = allowance_queries { get child_dashboard_path }

    assert_operator queries.count, :<=, BASELINE_ALLOWANCE_QUERIES, queries.join("\n")
  end

  private

  def allowance_queries(&block)
    queries = []
    subscriber = lambda do |_name, _start, _finish, _id, payload|
      queries << payload[:sql] if allowance_query?(payload)
    end
    ActiveSupport::Notifications.subscribed(subscriber, "sql.active_record", &block)
    queries
  end

  def allowance_query?(payload)
    payload[:name] != "SCHEMA" && payload[:sql].match?(/\b(allowances|allowance_periods)\b/)
  end
end

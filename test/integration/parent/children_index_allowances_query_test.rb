require "test_helper"

class Parent::ChildrenIndexAllowancesQueryTest < ActionDispatch::IntegrationTest
  setup do
    @parent = users(:parent)
    @children = [ child_profiles(:two), child_profiles(:three) ]
    @children.each do |child|
      Allowance.create!(child_profile: child, kind: :zakgeld, amount_cents: 500,
                        frequency: :weekly, due_day: 5, next_due_on: Date.today + 7)
    end
  end

  test "index does not issue a query per child for allowances" do
    sign_in_as @parent

    queries = allowance_queries { get parent_children_path }

    assert_response :success
    assert_operator queries.count, :<=, 2, queries.join("\n")
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

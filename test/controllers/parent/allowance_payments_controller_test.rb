require "test_helper"

module Parent
  class AllowancePaymentsControllerTest < ActionDispatch::IntegrationTest
    setup do
      post session_path, params: { email_address: users(:parent).email, password: "password" }
      @child = child_profiles(:two)
    end

    test "marking a payment given marks the oldest owed period" do
      allowance = Allowance.create!(child_profile: @child, kind: :zakgeld, amount_cents: 500,
                                    frequency: :weekly, due_day: 5, next_due_on: Date.today + 7)
      older = allowance.allowance_periods.create!(due_on: 2.weeks.ago.to_date, given: false)
      newer = allowance.allowance_periods.create!(due_on: 1.week.ago.to_date, given: false)

      post parent_child_allowance_payments_path(@child), params: { kind: "zakgeld" }

      assert_redirected_to parent_children_path

      assert_predicate older.reload, :given?
      assert_not newer.reload.given?
    end

    test "marking a payment given when two periods owed only marks the oldest" do
      allowance = Allowance.create!(child_profile: @child, kind: :zakgeld, amount_cents: 500,
                                    frequency: :weekly, due_day: 5, next_due_on: Date.today + 7)
      first  = allowance.allowance_periods.create!(due_on: 3.weeks.ago.to_date, given: false)
      second = allowance.allowance_periods.create!(due_on: 2.weeks.ago.to_date, given: false)
      third  = allowance.allowance_periods.create!(due_on: 1.week.ago.to_date, given: false)

      post parent_child_allowance_payments_path(@child), params: { kind: "zakgeld" }

      assert_predicate first.reload, :given?
      assert_not second.reload.given?
      assert_not third.reload.given?
    end

    test "marking kleedgeld given does not affect zakgeld" do
      zakgeld = Allowance.create!(child_profile: @child, kind: :zakgeld, amount_cents: 500,
                                  frequency: :weekly, due_day: 5, next_due_on: Date.today + 7)
      kleedgeld = Allowance.create!(child_profile: @child, kind: :kleedgeld, amount_cents: 3000,
                                    frequency: :monthly, due_day: 1, next_due_on: Date.today + 7)
      zakgeld_period   = zakgeld.allowance_periods.create!(due_on: 1.week.ago.to_date, given: false)
      kleedgeld_period = kleedgeld.allowance_periods.create!(due_on: 1.week.ago.to_date, given: false)

      post parent_child_allowance_payments_path(@child), params: { kind: "kleedgeld" }

      assert_not zakgeld_period.reload.given?
      assert_predicate kleedgeld_period.reload, :given?
    end

    test "no action taken when no owed periods exist" do
      Allowance.create!(child_profile: @child, kind: :zakgeld, amount_cents: 500,
                        frequency: :weekly, due_day: 5, next_due_on: Date.today + 7)

      post parent_child_allowance_payments_path(@child), params: { kind: "zakgeld" }

      assert_redirected_to parent_children_path
    end

    test "requires parent login" do
      delete session_path
      post parent_child_allowance_payments_path(@child), params: { kind: "zakgeld" }

      assert_response :redirect
    end
  end
end

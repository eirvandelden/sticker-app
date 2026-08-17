require "test_helper"

module Parent
  class AllowancesControllerTest < ActionDispatch::IntegrationTest
    setup do
      post session_path, params: { email_address: users(:parent).email, password: "password" }
      @child = child_profiles(:two)
    end

    test "creating an allowance for a child" do
      assert_difference -> { Allowance.count }, +1 do
        post parent_child_allowances_path(@child),
             params: { allowance: { kind: "zakgeld", amount_cents: 500, frequency: "weekly", due_day: 5 } }
      end
      assert_redirected_to edit_parent_child_path(@child)
    end

    test "creating an allowance sets next_due_on to the upcoming due day" do
      post parent_child_allowances_path(@child),
           params: { allowance: { kind: "zakgeld", amount_cents: 500, frequency: "weekly", due_day: 5 } }
      allowance = @child.allowances.find_by(kind: :zakgeld)
      assert_not_nil allowance.next_due_on
      assert allowance.next_due_on >= Date.today
      assert_equal 5, allowance.next_due_on.wday
    end

    test "invalid params re-render with unprocessable entity" do
      post parent_child_allowances_path(@child),
           params: { allowance: { kind: "zakgeld", amount_cents: "", frequency: "weekly", due_day: 5 } }
      assert_response :unprocessable_entity
    end

    test "invalid params re-render shows why the allowance was not saved" do
      post parent_child_allowances_path(@child),
           params: { allowance: { kind: "zakgeld", amount_cents: "", frequency: "weekly", due_day: 5 } }

      assert_select "aside[role=alert]", text: /Amount cents/
    end

    test "missing due_day re-renders instead of hanging" do
      post parent_child_allowances_path(@child),
           params: { allowance: { kind: "zakgeld", amount_cents: 500, frequency: "weekly" } }
      assert_response :unprocessable_entity
    end

    test "unrecognized kind re-renders instead of crashing" do
      post parent_child_allowances_path(@child),
           params: { allowance: { kind: "bogus", amount_cents: 500, frequency: "weekly", due_day: 5 } }
      assert_response :unprocessable_entity
    end

    test "unrecognized frequency re-renders instead of crashing" do
      post parent_child_allowances_path(@child),
           params: { allowance: { kind: "zakgeld", amount_cents: 500, frequency: "bogus", due_day: 5 } }
      assert_response :unprocessable_entity
    end

    test "updating an allowance amount" do
      allowance = Allowance.create!(child_profile: @child, kind: :zakgeld, amount_cents: 500,
                                    frequency: :weekly, due_day: 5, next_due_on: Date.today + 7)
      patch parent_child_allowance_path(@child, allowance),
            params: { allowance: { amount_cents: 750 } }
      assert_redirected_to edit_parent_child_path(@child)
      assert_equal 750, allowance.reload.amount_cents
    end

    test "updating an allowance leaves its kind, frequency and due day untouched" do
      allowance = Allowance.create!(child_profile: @child, kind: :zakgeld, amount_cents: 500,
                                    frequency: :weekly, due_day: 5, next_due_on: Date.today + 7)
      patch parent_child_allowance_path(@child, allowance),
            params: { allowance: { amount_cents: 750, kind: "kleedgeld", frequency: "monthly", due_day: 31 } }

      allowance.reload
      assert_equal 750, allowance.amount_cents
      assert_equal "zakgeld", allowance.kind
      assert_equal "weekly", allowance.frequency
      assert_equal 5, allowance.due_day
    end

    test "invalid update re-render shows why the allowance was not saved" do
      allowance = Allowance.create!(child_profile: @child, kind: :zakgeld, amount_cents: 500,
                                    frequency: :weekly, due_day: 5, next_due_on: Date.today + 7)
      patch parent_child_allowance_path(@child, allowance),
            params: { allowance: { amount_cents: "" } }

      assert_response :unprocessable_entity
      assert_select "aside[role=alert]", text: /Amount cents/
    end

    test "requires parent login" do
      delete session_path
      post parent_child_allowances_path(@child),
           params: { allowance: { kind: "zakgeld", amount_cents: 500, frequency: "weekly", due_day: 5 } }
      assert_response :redirect
    end
  end
end

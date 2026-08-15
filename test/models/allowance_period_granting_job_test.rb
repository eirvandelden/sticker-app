require "test_helper"

class AllowancePeriodGrantingJobTest < ActiveSupport::TestCase
  test "grants a period for each allowance that is due" do
    due_allowance = Allowance.create!(
      child_profile: child_profiles(:two),
      kind: :zakgeld, amount_cents: 500, frequency: :weekly,
      due_day: Date.today.wday, next_due_on: Date.today
    )
    future_allowance = Allowance.create!(
      child_profile: child_profiles(:three),
      kind: :zakgeld, amount_cents: 500, frequency: :weekly,
      due_day: 5, next_due_on: Date.today + 7
    )

    AllowancePeriodGrantingJob.perform_now

    assert_equal 1, due_allowance.allowance_periods.count
    assert_equal 0, future_allowance.allowance_periods.count
  end

  test "does not double-grant when run twice on the same day" do
    allowance = Allowance.create!(
      child_profile: child_profiles(:two),
      kind: :zakgeld, amount_cents: 500, frequency: :weekly,
      due_day: Date.today.wday, next_due_on: Date.today
    )

    AllowancePeriodGrantingJob.perform_now

    # Manually reset next_due_on back so we can test idempotency (edge-case guard)
    allowance.update_column(:next_due_on, Date.today)

    AllowancePeriodGrantingJob.perform_now

    assert_equal 1, allowance.allowance_periods.count
  end
end

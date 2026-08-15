require "test_helper"
require "timeout"

class AllowanceTest < ActiveSupport::TestCase
  def setup
    @child = child_profiles(:two)
  end

  # --- validations ---

  test "requires kind, amount_cents, frequency, due_day, next_due_on" do
    allowance = Allowance.new(child_profile: @child)
    assert_not allowance.valid?
    assert allowance.errors[:kind].any?
    assert allowance.errors[:amount_cents].any?
    assert allowance.errors[:frequency].any?
    assert allowance.errors[:due_day].any?
    assert allowance.errors[:next_due_on].any?
  end

  test "one allowance per child per kind" do
    Allowance.create!(child_profile: @child, kind: :zakgeld, amount_cents: 500,
                      frequency: :weekly, due_day: 5, next_due_on: Date.today)
    duplicate = Allowance.new(child_profile: @child, kind: :zakgeld, amount_cents: 300,
                              frequency: :monthly, due_day: 1, next_due_on: Date.today)
    assert_not duplicate.valid?
  end

  test "two different kinds allowed for same child" do
    Allowance.create!(child_profile: @child, kind: :zakgeld, amount_cents: 500,
                      frequency: :weekly, due_day: 5, next_due_on: Date.today)
    kleedgeld = Allowance.new(child_profile: @child, kind: :kleedgeld, amount_cents: 3000,
                              frequency: :monthly, due_day: 1, next_due_on: Date.today)
    assert kleedgeld.valid?
  end

  # --- owed_periods ---

  test "owed_periods returns only unpaid periods" do
    allowance = Allowance.create!(child_profile: @child, kind: :zakgeld, amount_cents: 500,
                                  frequency: :weekly, due_day: 5, next_due_on: Date.today)
    paid   = allowance.allowance_periods.create!(due_on: 1.week.ago.to_date, given: true)
    unpaid = allowance.allowance_periods.create!(due_on: Date.today, given: false)

    owed = allowance.owed_periods
    assert_includes owed, unpaid
    assert_not_includes owed, paid
  end

  # --- grant_due_period! ---

  test "grant_due_period! creates a period when next_due_on is today" do
    allowance = Allowance.create!(child_profile: @child, kind: :zakgeld, amount_cents: 500,
                                  frequency: :weekly, due_day: Date.today.wday,
                                  next_due_on: Date.today)
    assert_difference -> { allowance.allowance_periods.count }, +1 do
      allowance.grant_due_period!
    end
    assert_equal Date.today, allowance.allowance_periods.last.due_on
  end

  test "grant_due_period! creates a period when next_due_on is in the past" do
    allowance = Allowance.create!(child_profile: @child, kind: :zakgeld, amount_cents: 500,
                                  frequency: :weekly, due_day: 1.week.ago.to_date.wday,
                                  next_due_on: 1.week.ago.to_date)
    assert_difference -> { allowance.allowance_periods.count }, +1 do
      allowance.grant_due_period!
    end
  end

  test "grant_due_period! does not create a period when next_due_on is in the future" do
    allowance = Allowance.create!(child_profile: @child, kind: :zakgeld, amount_cents: 500,
                                  frequency: :weekly, due_day: 5,
                                  next_due_on: Date.today + 3)
    assert_no_difference -> { allowance.allowance_periods.count } do
      allowance.grant_due_period!
    end
  end

  test "grant_due_period! advances next_due_on after granting" do
    today = Date.today
    allowance = Allowance.create!(child_profile: @child, kind: :zakgeld, amount_cents: 500,
                                  frequency: :weekly, due_day: today.wday,
                                  next_due_on: today)
    allowance.grant_due_period!
    assert_equal today + 7, allowance.reload.next_due_on
  end

  test "grant_due_period! does not create duplicate period for same due_on" do
    today = Date.today
    allowance = Allowance.create!(child_profile: @child, kind: :zakgeld, amount_cents: 500,
                                  frequency: :weekly, due_day: today.wday,
                                  next_due_on: today)
    allowance.grant_due_period!
    allowance.update!(next_due_on: today)
    assert_no_difference -> { allowance.allowance_periods.count } do
      allowance.grant_due_period!
    end
  end

  # --- next_occurrence_of (invalid day) ---

  test "next_occurrence_of returns nil instead of hanging when due_day is blank" do
    allowance = Allowance.new(frequency: :weekly)

    result = Timeout.timeout(2) { allowance.next_occurrence_of(nil, after: Date.today) }

    assert_nil result
  end

  test "next_occurrence_of returns nil instead of hanging when due_day is not a valid weekday" do
    allowance = Allowance.new(frequency: :weekly)

    result = Timeout.timeout(2) { allowance.next_occurrence_of(15, after: Date.today) }

    assert_nil result
  end

  # --- next_occurrence_of (weekly) ---

  test "weekly next_occurrence_of returns next date matching the given weekday" do
    allowance = Allowance.new(frequency: :weekly)
    monday = Date.new(2026, 8, 17)  # known Monday
    friday_wday = 5
    result = allowance.next_occurrence_of(friday_wday, after: monday)
    assert_equal 5, result.wday
    assert result > monday
  end

  test "weekly next_occurrence_of returns today when today matches the weekday" do
    allowance = Allowance.new(frequency: :weekly)
    friday = Date.new(2026, 8, 21)  # known Friday
    result = allowance.next_occurrence_of(5, after: friday - 1)
    assert_equal friday, result
  end

  # --- next_occurrence_of (monthly) ---

  test "monthly next_occurrence_of returns the given day in the next month" do
    allowance = Allowance.new(frequency: :monthly)
    jan1 = Date.new(2026, 1, 1)
    result = allowance.next_occurrence_of(15, after: jan1)
    assert_equal Date.new(2026, 1, 15), result
  end

  test "monthly next_occurrence_of falls back to last day when day does not exist in month" do
    allowance = Allowance.new(frequency: :monthly)
    jan30 = Date.new(2026, 1, 30)
    result = allowance.next_occurrence_of(31, after: jan30 - 1)
    assert_equal Date.new(2026, 1, 31), result

    # February in non-leap year: day 31 → Feb 28
    feb_start = Date.new(2026, 2, 1)
    result_feb = allowance.next_occurrence_of(31, after: feb_start - 1)
    assert_equal Date.new(2026, 2, 28), result_feb
  end

  test "monthly next_occurrence_of advances to next month when day has passed" do
    allowance = Allowance.new(frequency: :monthly)
    jan16 = Date.new(2026, 1, 16)
    result = allowance.next_occurrence_of(15, after: jan16)
    assert_equal Date.new(2026, 2, 15), result
  end
end

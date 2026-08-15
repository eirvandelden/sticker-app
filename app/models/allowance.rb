class Allowance < ApplicationRecord
  belongs_to :child_profile
  has_many :allowance_periods, dependent: :destroy

  enum :kind, { zakgeld: 0, kleedgeld: 1 }
  enum :frequency, { weekly: 0, monthly: 1 }

  validates :kind, :amount_cents, :frequency, :due_day, :next_due_on, presence: true
  validates :kind, uniqueness: { scope: :child_profile_id }

  def owed_periods
    allowance_periods.where(given: false)
  end

  def grant_due_period!
    return if next_due_on > Date.today
    return if allowance_periods.exists?(due_on: next_due_on)

    allowance_periods.create!(due_on: next_due_on)
    update!(next_due_on: next_occurrence_of(due_day, after: next_due_on))
  end

  def next_occurrence_of(day, after:)
    return nil unless valid_due_day?(day)

    if weekly?
      next_weekday(day, after: after)
    else
      next_month_day(day, after: after)
    end
  end

  private

  def valid_due_day?(day)
    return false unless day.is_a?(Integer)

    weekly? ? (0..6).cover?(day) : (1..31).cover?(day)
  end

  def next_weekday(wday, after:)
    candidate = after + 1
    candidate += 1 until candidate.wday == wday
    candidate
  end

  def next_month_day(day, after:)
    candidate = Date.new(after.year, after.month, [ day, after.end_of_month.day ].min)
    if candidate <= after
      next_month = after >> 1
      candidate = Date.new(next_month.year, next_month.month, [ day, next_month.end_of_month.day ].min)
    end
    candidate
  end
end

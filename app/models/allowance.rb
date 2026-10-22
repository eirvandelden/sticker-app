# Represents a child's recurring pocket money or clothing money.
class Allowance < ApplicationRecord
  belongs_to :child_profile
  has_many :allowance_periods, dependent: :destroy

  enum :kind, { zakgeld: 0, kleedgeld: 1 }
  enum :frequency, { weekly: 0, monthly: 1 }

  validates :kind, presence: true
  validates :amount_cents, presence: true
  validates :frequency, presence: true
  validates :due_day, presence: true
  validates :next_due_on, presence: true
  validates :kind, uniqueness: { scope: :child_profile_id }
  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
  validate :due_day_matches_frequency

  # Sets the kind, ignoring a value that is not a valid kind.
  # @rbs (String | Symbol | Integer | nil value) -> void
  def kind=(value)
    super
  rescue ArgumentError
    nil
  end

  # Sets the frequency, ignoring a value that is not a valid frequency.
  # @rbs (String | Symbol | Integer | nil value) -> void
  def frequency=(value)
    super
  rescue ArgumentError
    nil
  end

  # Returns the periods that are due but not yet paid.
  # @rbs () -> Array[AllowancePeriod]
  def owed_periods
    allowance_periods.to_a.reject(&:given?)
  end

  # Creates a period when the allowance is due, then moves the next due date forward.
  # @rbs () -> void
  def grant_due_period!
    return if next_due_on > Date.today
    return if allowance_periods.exists?(due_on: next_due_on)

    begin
      allowance_periods.create!(due_on: next_due_on)
    rescue ActiveRecord::RecordNotUnique
      return
    end

    update!(next_due_on: next_occurrence_of(due_day, after: next_due_on))
  end

  # Returns the first due date after the given date, or nil for an invalid due day.
  # @rbs (untyped day, after: Date) -> Date?
  def next_occurrence_of(day, after:)
    return nil unless valid_due_day?(day)

    if weekly?
      next_weekday(day, after: after)
    else
      next_month_day(day, after: after)
    end
  end

  private

  # Validates that the due day fits the weekly or monthly frequency.
  # @rbs () -> void
  def due_day_matches_frequency
    return if due_day.nil? || frequency.nil?
    return if valid_due_day?(due_day)

    errors.add(:due_day, :invalid)
  end

  # Tells whether the day is a weekday number for weekly or a day of the month for monthly.
  # @rbs (untyped day) -> bool
  def valid_due_day?(day)
    return false unless day.is_a?(Integer)

    weekly? ? (0..6).cover?(day) : (1..31).cover?(day)
  end

  # Returns the first date after the given date that falls on the weekday.
  # @rbs (Integer wday, after: Date) -> Date
  def next_weekday(wday, after:)
    candidate = after + 1
    candidate += 1 until candidate.wday == wday
    candidate
  end

  # Returns the next date after the given date on the day of the month, capped at month end.
  # @rbs (Integer day, after: Date) -> Date
  def next_month_day(day, after:)
    candidate = Date.new(after.year, after.month, [ day, after.end_of_month.day ].min)
    if candidate <= after
      next_month = after >> 1
      candidate = Date.new(next_month.year, next_month.month, [ day, next_month.end_of_month.day ].min)
    end
    candidate
  end
end

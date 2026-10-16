class AllowancePeriodGrantingJob < ApplicationJob
  queue_as :default

  # @rbs () -> void
  def perform
    Allowance.find_each(&:grant_due_period!)
  end
end

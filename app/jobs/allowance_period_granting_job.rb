# Creates the due period of every allowance.
class AllowancePeriodGrantingJob < ApplicationJob
  queue_as :default

  # Grants the due period on each allowance.
  # @rbs () -> void
  def perform
    Allowance.find_each(&:grant_due_period!)
  end
end

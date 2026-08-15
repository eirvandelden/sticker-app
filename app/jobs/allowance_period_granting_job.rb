class AllowancePeriodGrantingJob < ApplicationJob
  queue_as :default

  def perform
    Allowance.find_each(&:grant_due_period!)
  end
end

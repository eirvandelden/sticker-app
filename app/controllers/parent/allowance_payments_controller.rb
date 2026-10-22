# Groups the controllers that parents use.
module Parent
  # Lets parents mark an allowance as paid.
  class AllowancePaymentsController < ApplicationController
    before_action :ensure_parent

    # Marks the oldest owed period of the child's allowance as given.
    # @rbs () -> void
    def create
      child    = ChildProfile.find(params[:child_id])
      kind     = params[:kind]
      allowance = child.allowances.find_by(kind: kind)
      period   = allowance&.owed_periods&.min_by(&:due_on)

      period&.update(given: true)

      redirect_to parent_children_path
    end
  end
end

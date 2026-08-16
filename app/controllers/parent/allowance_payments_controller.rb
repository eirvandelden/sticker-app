module Parent
  class AllowancePaymentsController < ApplicationController
    before_action :ensure_parent

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

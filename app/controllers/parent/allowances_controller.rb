module Parent
  class AllowancesController < ApplicationController
    before_action :ensure_parent
    before_action :set_child

    def create
      allowance = @child.allowances.build(allowance_params)
      allowance.next_due_on = allowance.next_occurrence_of(allowance.due_day, after: Date.today - 1)

      if allowance.save
        redirect_to edit_parent_child_path(@child), notice: t("flash.parent.allowances.created")
      else
        @child_profile = @child
        render "parent/children/edit", status: :unprocessable_entity
      end
    end

    def update
      allowance = @child.allowances.find(params[:id])

      if allowance.update(allowance_params)
        redirect_to edit_parent_child_path(@child), notice: t("flash.parent.allowances.updated")
      else
        @child_profile = @child
        render "parent/children/edit", status: :unprocessable_entity
      end
    end

    private

    def set_child
      @child = ChildProfile.find(params[:child_id])
    end

    def allowance_params
      params.expect(allowance: [ :kind, :amount_cents, :frequency, :due_day ])
    end
  end
end

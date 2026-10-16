# Groups the controllers that parents use.
module Parent
  # Lets parents manage a child's allowances.
  class AllowancesController < ApplicationController
    before_action :ensure_parent
    before_action :set_child

    # Adds an allowance for the child, or shows the form with errors.
    # @rbs () -> void
    def create
      allowance = @child.allowances.build(allowance_params)
      allowance.next_due_on = allowance.next_occurrence_of(allowance.due_day, after: Date.today - 1)

      if allowance.save
        redirect_to edit_parent_child_path(@child), notice: t("flash.parent.allowances.created")
      else
        @invalid_allowance = allowance
        render "parent/children/edit", status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotUnique
      allowance.errors.add(:kind, :taken)
      @invalid_allowance = allowance
      render "parent/children/edit", status: :unprocessable_entity
    end

    # Changes the amount of the child's allowance.
    # @rbs () -> void
    def update
      allowance = @child.allowances.find(params[:id])

      if allowance.update(amount_params)
        redirect_to edit_parent_child_path(@child), notice: t("flash.parent.allowances.updated")
      else
        @invalid_allowance = allowance
        render "parent/children/edit", status: :unprocessable_entity
      end
    end

    # Removes the child's allowance.
    # @rbs () -> void
    def destroy
      @child.allowances.find(params[:id]).destroy
      redirect_to edit_parent_child_path(@child), notice: t("flash.parent.allowances.destroyed")
    end

    private

    # Loads the child profile from the request.
    # @rbs () -> void
    def set_child
      @child = ChildProfile.find(params[:child_id])
    end

    # Permits the fields for a new allowance.
    # @rbs () -> ActionController::Parameters
    def allowance_params
      params.expect(allowance: [ :kind, :amount_cents, :frequency, :due_day ])
    end

    # Permits only the amount of an existing allowance.
    # @rbs () -> ActionController::Parameters
    def amount_params
      params.expect(allowance: [ :amount_cents ])
    end
  end
end

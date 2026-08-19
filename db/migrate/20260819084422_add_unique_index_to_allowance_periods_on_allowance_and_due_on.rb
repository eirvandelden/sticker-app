class AddUniqueIndexToAllowancePeriodsOnAllowanceAndDueOn < ActiveRecord::Migration[8.1]
  def change
    remove_index :allowance_periods, :allowance_id
    add_index :allowance_periods, [ :allowance_id, :due_on ], unique: true
  end
end

class CreateAllowancePeriods < ActiveRecord::Migration[8.1]
  def change
    create_table :allowance_periods do |t|
      t.references :allowance, null: false, foreign_key: true
      t.date :due_on, null: false
      t.boolean :given, null: false, default: false

      t.timestamps
    end
  end
end

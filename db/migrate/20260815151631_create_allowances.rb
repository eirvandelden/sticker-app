class CreateAllowances < ActiveRecord::Migration[8.1]
  def change
    create_table :allowances do |t|
      t.references :child_profile, null: false, foreign_key: true, index: false
      t.integer :kind, null: false
      t.integer :amount_cents, null: false
      t.integer :frequency, null: false
      t.integer :due_day, null: false
      t.date :next_due_on, null: false

      t.timestamps
    end

    add_index :allowances, [ :child_profile_id, :kind ], unique: true
  end
end

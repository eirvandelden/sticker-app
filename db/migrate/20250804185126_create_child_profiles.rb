class CreateChildProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :child_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :sticker_goal

      t.timestamps
    end
  end
end

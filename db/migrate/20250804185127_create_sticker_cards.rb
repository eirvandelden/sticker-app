class CreateStickerCards < ActiveRecord::Migration[8.0]
  def change
    create_table :sticker_cards do |t|
      t.references :child_profile, null: false, foreign_key: true
      t.boolean :reward_given
      t.boolean :completed

      t.timestamps
    end
  end
end

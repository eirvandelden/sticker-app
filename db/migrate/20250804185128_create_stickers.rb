class CreateStickers < ActiveRecord::Migration[8.0]
  def change
    create_table :stickers do |t|
      t.references :sticker_card, null: false, foreign_key: true
      t.integer :kind
      t.string :emoji
      t.string :note
      t.integer :giver_id

      t.timestamps
    end
  end
end

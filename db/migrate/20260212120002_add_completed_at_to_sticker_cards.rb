class AddCompletedAtToStickerCards < ActiveRecord::Migration[8.0]
  def change
    add_column :sticker_cards, :completed_at, :datetime
    add_index :sticker_cards, :completed_at

    # Backfill existing completed cards
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE sticker_cards
          SET completed_at = updated_at
          WHERE completed = true AND completed_at IS NULL
        SQL
      end
    end
  end
end

class AddStickerGoalToStickerCards < ActiveRecord::Migration[8.1]
  DEFAULT_STICKER_GOAL = 10

  def up
    add_column :sticker_cards, :sticker_goal, :integer, default: DEFAULT_STICKER_GOAL, null: false
    backfill_sticker_goals
  end

  def down
    remove_column :sticker_cards, :sticker_goal
  end

  private

  def backfill_sticker_goals
    execute <<~SQL.squish
      UPDATE sticker_cards
      SET sticker_goal = child_profiles.sticker_goal
      FROM child_profiles
      WHERE child_profiles.id = sticker_cards.child_profile_id
    SQL
  end
end

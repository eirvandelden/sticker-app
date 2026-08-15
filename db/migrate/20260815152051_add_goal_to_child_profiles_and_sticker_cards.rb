class AddGoalToChildProfilesAndStickerCards < ActiveRecord::Migration[8.1]
  def change
    add_column :child_profiles, :goal, :string
    add_column :sticker_cards, :goal, :string
    add_column :sticker_cards, :goal_overridden, :boolean, default: false, null: false
  end
end

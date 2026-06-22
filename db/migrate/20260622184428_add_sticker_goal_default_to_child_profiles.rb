class AddStickerGoalDefaultToChildProfiles < ActiveRecord::Migration[8.1]
  def change
    change_column_default :child_profiles, :sticker_goal, from: nil, to: 10
  end
end

class AddStickerGoalDefaultToChildProfiles < ActiveRecord::Migration[8.1]
  CHILD_ROLE = 0
  DEFAULT_STICKER_GOAL = 10

  def up
    change_column_default :child_profiles, :sticker_goal, from: nil, to: 10
    change_column_null :child_profiles, :sticker_goal, false, 10
    provision_missing_child_profiles
    provision_missing_sticker_cards
  end

  def down
    change_column_null :child_profiles, :sticker_goal, true
    change_column_default :child_profiles, :sticker_goal, from: 10, to: nil
  end

  private

  def provision_missing_child_profiles
    execute <<~SQL.squish
      INSERT INTO child_profiles (user_id, sticker_goal, created_at, updated_at)
      SELECT users.id, #{DEFAULT_STICKER_GOAL}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM users
      LEFT OUTER JOIN child_profiles ON child_profiles.user_id = users.id
      WHERE users.role = #{CHILD_ROLE}
        AND child_profiles.id IS NULL
    SQL
  end

  def provision_missing_sticker_cards
    execute <<~SQL.squish
      INSERT INTO sticker_cards (child_profile_id, reward_given, completed, created_at, updated_at)
      SELECT child_profiles.id, 0, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM child_profiles
      LEFT OUTER JOIN sticker_cards ON sticker_cards.child_profile_id = child_profiles.id
      WHERE sticker_cards.id IS NULL
    SQL
  end
end

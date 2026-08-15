class AddBirthdateToChildProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :child_profiles, :birthdate, :date
  end
end

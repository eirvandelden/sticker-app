class AddNameToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :name, :string
    execute "UPDATE users SET name = SUBSTR(email, 1, INSTR(email, '@') - 1)"
    change_column_null :users, :name, false
  end

  def down
    remove_column :users, :name
  end
end

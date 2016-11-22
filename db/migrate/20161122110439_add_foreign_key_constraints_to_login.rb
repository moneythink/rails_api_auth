class AddForeignKeyConstraintsToLogin < ActiveRecord::Migration

  def change
    add_foreign_key :logins, :users
  rescue
    true
  end

end

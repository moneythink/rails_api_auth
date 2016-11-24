class AddForeignKeyConstraintsToLogin < ActiveRecord::Migration

  def change
    return if !foreign_keys(:logins).select {|fk| fk.to_table == 'users' }.empty?
    add_foreign_key :logins, :users
  end

end

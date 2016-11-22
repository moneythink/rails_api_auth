class AddClientToLogins < ActiveRecord::Migration

  def up
    return if column_exists?(:logins, :client)
    add_column :logins, :client, :string
  end

  def down
    remove_column :logins, :client
  end

end

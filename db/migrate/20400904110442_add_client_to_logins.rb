class AddClientToIdentification < ActiveRecord::Migration

  def change
    add_column :logins, :client, :string
  end

end
class AddProviderToLogin < ActiveRecord::Migration

  def up
    return if column_exists?(:logins, :provider)
    add_column :logins, :provider, :string
    rename_column :logins, :facebook_uid, :uid
  end

  def down
    remove_column :logins, :provider
    rename_column :logins, :uid, :facebook_uid
  end

end

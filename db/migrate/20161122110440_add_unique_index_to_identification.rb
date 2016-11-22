class AddUniqueIndexToIdentification < ActiveRecord::Migration

  def up
    return if index_exists?(:logins, :identification)
    add_index :logins, :identification, unique: true
  end

  def down
    remove_index :logins, :identification
  end

end

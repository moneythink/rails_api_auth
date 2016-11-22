class RemoveUniqueIndexFromIdentification < ActiveRecord::Migration

  def change
    # remove previous, unique index
    remove_index :logins, :identification

    # add new index without uniqueness
    add_index :logins, :identification
  end

end

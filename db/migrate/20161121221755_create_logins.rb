class CreateLogins < ActiveRecord::Migration

  def up
    return if table_exists?(:logins)

    create_table :logins, primary_key_options(:id) do |t|
      t.string :identification,  null: false
      t.string :password_digest, null: true
      t.string :oauth2_token,    null: false
      t.string :facebook_uid
      t.string :single_use_oauth2_token

      t.references :user, primary_key_options(:type)

      t.timestamps
    end
  end

  def down
    drop_table :logins
  end

  private

    def primary_key_options(option_name)
      RailsApiAuth.primary_key_type ? { option_name => RailsApiAuth.primary_key_type } : {}
    end

end

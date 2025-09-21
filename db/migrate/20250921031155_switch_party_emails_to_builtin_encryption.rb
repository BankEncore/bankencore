class SwitchPartyEmailsToBuiltinEncryption < ActiveRecord::Migration[8.0]
  def up
    add_column :party_emails, :email, :string, limit: 510

    # Drop legacy columns from pre-built-in setups
    remove_column :party_emails, :encrypted_email, :binary, if_exists: true
    remove_column :party_emails, :encrypted_email_iv, :binary, if_exists: true
    remove_column :party_emails, :encrypted_email_salt, :binary, if_exists: true

    # Optional: drop if you won't use blind index / masking any more
    # (Leaving them if you still want them.)
    # remove_column :party_emails, :email_bidx, :string, if_exists: true
    # remove_column :party_emails, :email_masked, :string, if_exists: true
  end

  def down
    add_column :party_emails, :encrypted_email, :binary
    add_column :party_emails, :encrypted_email_iv, :binary
    add_column :party_emails, :encrypted_email_salt, :binary
    add_column :party_emails, :email_bidx, :string
    add_column :party_emails, :email_masked, :string

    remove_column :party_emails, :email, :string
  end
end

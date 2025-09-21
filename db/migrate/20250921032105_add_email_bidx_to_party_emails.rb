class AddEmailBidxToPartyEmails < ActiveRecord::Migration[8.0]
  def up
    # 1) Add if missing
    unless column_exists?(:party_emails, :email_bidx)
      add_column :party_emails, :email_bidx, :binary, limit: 32 # null set below
    end

    # 2) Normalize type/limit and nullability
    normalize_email_bidx!

    # 3) Ensure composite index exists
    unless index_exists?(:party_emails, [:party_id, :email_bidx], name: "index_party_emails_on_party_and_bidx")
      add_index :party_emails, [:party_id, :email_bidx], unique: true, name: "index_party_emails_on_party_and_bidx"
    end
  end

  def down
    remove_index :party_emails, name: "index_party_emails_on_party_and_bidx" if index_exists?(:party_emails, [:party_id, :email_bidx], name: "index_party_emails_on_party_and_bidx")
    remove_column :party_emails, :email_bidx if column_exists?(:party_emails, :email_bidx)
  end

  private

  def normalize_email_bidx!
    col = connection.columns(:party_emails).find { |c| c.name == "email_bidx" }

    # Fix type/limit if needed
    unless col.sql_type =~ /binary/i && col.limit == 32
      change_column :party_emails, :email_bidx, :binary, limit: 32
    end

    # Enforce NOT NULL (will fail if rows exist with NULL; set defaults first if needed)
    change_column_null :party_emails, :email_bidx, false
  end
end

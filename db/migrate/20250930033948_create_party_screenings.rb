class CreatePartyScreenings < ActiveRecord::Migration[7.2]
  def change
    create_table :party_screenings do |t|
      t.references :party, null: false, foreign_key: { on_delete: :cascade }
      t.integer :vendor, null: false, default: 0      # :manual only for now
      t.integer :kind, null: false                    # :sanctions, :pep, :watchlist, :adverse_media, :idv
      t.integer :status, null: false, default: 0      # :pending, :matched, :clear, :needs_review, :rejected, :error

      # Query snapshot (what you searched with)
      t.string  :query_name
      t.date    :query_dob
      t.string  :query_country, limit: 2
      t.string  :query_identifier_type
      t.string  :query_identifier_last4

      # Result summary (what you found)
      t.string  :vendor_ref
      t.decimal :vendor_score, precision: 6, scale: 2
      t.datetime :requested_at
      t.datetime :completed_at
      t.datetime :expires_at
      t.json :vendor_payload, null: false
      t.text :notes

      t.timestamps
    end
    add_index :party_screenings, :expires_at
    add_index :party_screenings, [ :party_id, :vendor, :kind, :status ], name: "idx_screenings_state"
    add_column :parties, :last_screened_at, :datetime
  end
end

# db/migrate/20250930_remove_default_from_vendor_payload.rb
class RemoveDefaultFromVendorPayload < ActiveRecord::Migration[7.2]
  def change
    change_column_default :party_screenings, :vendor_payload, from: {}, to: nil
  end
end

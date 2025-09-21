# db/migrate/XXXXXX_create_customer_number_counters.rb
class CreateCustomerNumberCounters < ActiveRecord::Migration[8.0]
  def change
    create_table :customer_number_counters do |t|
      t.integer :current_value, null: false
      t.integer :min_value,     null: false, default: 1001
      t.integer :max_value,     null: false, default: 9_999_999
      t.timestamps
    end

    # single-row table; seed initial row
    reversible do |dir|
      dir.up do
        execute <<~SQL
          INSERT INTO customer_number_counters (current_value, min_value, max_value, created_at, updated_at)
          SELECT 1000, 1001, 9999999, NOW(), NOW()
          WHERE NOT EXISTS (SELECT 1 FROM customer_number_counters);
        SQL
      end
    end
  end
end

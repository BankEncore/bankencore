class CreateRefRegions < ActiveRecord::Migration[8.0]
  def change
    create_table :ref_regions, id: false, primary_key: :code do |t|
      t.string :code, null: false, primary_key: true, limit: 10
      t.string :name, null: false
      t.string :country_code, null: false, limit: 2

      t.timestamps
    end
    add_index :ref_regions, :code, unique: true
    add_foreign_key :ref_regions, :ref_countries, column: :country_code, primary_key: :code
  end
end

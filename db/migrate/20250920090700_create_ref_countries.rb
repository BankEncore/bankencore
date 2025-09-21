class CreateRefCountries < ActiveRecord::Migration[8.0]
  def change
    create_table :ref_countries, id: false, primary_key: :code do |t|
      t.string :code, null: false, primary_key: true, limit: 2
      t.string :name, null: false

      t.timestamps
    end
    add_index :ref_countries, :code, unique: true
  end
end

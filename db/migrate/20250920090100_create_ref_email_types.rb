class CreateRefEmailTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :ref_email_types, id: false, primary_key: :code do |t|
      t.string :code, null: false, primary_key: true
      t.string :name, null: false

      t.timestamps
    end
    add_index :ref_email_types, :code, unique: true
  end
end

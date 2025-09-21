class AddUniqueIndexToPartiesCustomerNumber < ActiveRecord::Migration[8.0]
  def up
    change_column :parties, :customer_number, :string, limit: 10

    if index_exists?(:parties, :customer_number, name: "index_parties_on_customer_number")
      remove_index :parties, name: "index_parties_on_customer_number"
    end

    add_index :parties, :customer_number, unique: true, name: "index_parties_on_customer_number"
  end

  def down
    remove_index :parties, name: "index_parties_on_customer_number" if index_exists?(:parties, :customer_number, name: "index_parties_on_customer_number")
    add_index :parties, :customer_number unless index_exists?(:parties, :customer_number)
  end
end

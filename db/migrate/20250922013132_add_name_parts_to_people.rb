class AddNamePartsToPeople < ActiveRecord::Migration[8.0]
  def change
    add_column :party_people, :middle_name, :string
    add_column :party_people, :name_suffix, :string
    add_column :party_people, :courtesy_title, :string
  end
end
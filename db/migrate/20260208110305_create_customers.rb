class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.text :address
      t.string :id_number
      t.boolean :active, default: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :customers, :email
    add_index :customers, :phone
    add_index :customers, :deleted_at
  end
end

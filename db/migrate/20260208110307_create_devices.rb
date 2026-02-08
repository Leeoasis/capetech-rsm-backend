class CreateDevices < ActiveRecord::Migration[8.1]
  def change
    create_table :devices do |t|
      t.references :customer, null: false, foreign_key: true
      t.integer :device_type
      t.string :brand
      t.string :model
      t.string :serial_number
      t.string :imei
      t.string :password_pin
      t.text :notes
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :devices, :device_type
    add_index :devices, :serial_number
    add_index :devices, :imei
    add_index :devices, :deleted_at
  end
end

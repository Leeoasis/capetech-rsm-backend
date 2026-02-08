class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :repair_ticket, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2
      t.integer :payment_method
      t.datetime :payment_date
      t.string :reference_number
      t.text :notes
      t.integer :received_by_user_id

      t.timestamps
    end

    add_index :payments, :payment_date
    add_index :payments, :payment_method
    add_foreign_key :payments, :users, column: :received_by_user_id
  end
end

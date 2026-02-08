class CreateRepairTickets < ActiveRecord::Migration[8.1]
  def change
    create_table :repair_tickets do |t|
      t.string :ticket_number
      t.references :device, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.integer :assigned_technician_id
      t.text :fault_description
      t.text :accessories_received
      t.decimal :estimated_cost, precision: 10, scale: 2
      t.decimal :actual_cost, precision: 10, scale: 2
      t.integer :status
      t.integer :priority
      t.datetime :completed_at
      t.datetime :collected_at

      t.timestamps
    end

    add_index :repair_tickets, :ticket_number, unique: true
    add_index :repair_tickets, :assigned_technician_id
    add_index :repair_tickets, :status
    add_index :repair_tickets, :priority
    add_index :repair_tickets, :created_at
    add_foreign_key :repair_tickets, :users, column: :assigned_technician_id
  end
end

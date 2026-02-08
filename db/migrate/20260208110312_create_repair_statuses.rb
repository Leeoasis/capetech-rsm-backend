class CreateRepairStatuses < ActiveRecord::Migration[8.1]
  def change
    create_table :repair_statuses do |t|
      t.references :repair_ticket, null: false, foreign_key: true
      t.integer :status
      t.text :notes
      t.integer :changed_by_user_id

      t.timestamps
    end

    add_index :repair_statuses, :created_at
    add_foreign_key :repair_statuses, :users, column: :changed_by_user_id
  end
end

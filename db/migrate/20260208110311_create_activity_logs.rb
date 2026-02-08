class CreateActivityLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :activity_logs do |t|
      t.integer :repair_ticket_id
      t.references :user, null: false, foreign_key: true
      t.string :action_type
      t.text :description
      t.jsonb :metadata

      t.timestamps
    end

    add_index :activity_logs, :repair_ticket_id
    add_index :activity_logs, :action_type
    add_index :activity_logs, :created_at
  end
end

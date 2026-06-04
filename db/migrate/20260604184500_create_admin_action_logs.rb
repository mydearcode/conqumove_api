class CreateAdminActionLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :admin_action_logs, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :action_name, null: false
      t.string :status, null: false
      t.jsonb :metadata, null: false, default: {}
      t.datetime :occurred_at, null: false
      t.timestamps
    end

    add_index :admin_action_logs, [:user_id, :action_name, :occurred_at]
    add_index :admin_action_logs, :status
  end
end

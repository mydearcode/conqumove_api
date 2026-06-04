class CreateLeaderboardSnapshots < ActiveRecord::Migration[8.1]
  def change
    create_table :leaderboard_snapshots, id: :uuid do |t|
      t.string :scope, null: false
      t.jsonb :data, null: false, default: {}
      t.timestamps
    end

    add_index :leaderboard_snapshots, [:scope, :created_at]
  end
end

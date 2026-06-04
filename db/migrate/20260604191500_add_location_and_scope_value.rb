class AddLocationAndScopeValue < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :city, :string
    add_column :users, :region, :string

    add_column :leaderboard_snapshots, :scope_value, :string
    add_index :leaderboard_snapshots, [:scope, :scope_value, :created_at]
    remove_index :leaderboard_snapshots, [:scope, :created_at]
  end
end

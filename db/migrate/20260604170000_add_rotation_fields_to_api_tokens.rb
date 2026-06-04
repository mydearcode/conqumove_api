class AddRotationFieldsToApiTokens < ActiveRecord::Migration[8.1]
  def change
    add_column :api_tokens, :token_kind, :string, null: false, default: "access"
    add_column :api_tokens, :revoked_at, :datetime
    add_reference :api_tokens, :replaced_by, foreign_key: { to_table: :api_tokens }, type: :uuid

    add_index :api_tokens, :token_kind
  end
end

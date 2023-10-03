class EditUsers < ActiveRecord::Migration[7.0]
  def change
    add_index :users, [:session_token, :email], unique: true
  end
end

class HttpEnvTooSmall < ActiveRecord::Migration[4.2]
  def up
    change_column :requests, :http_env, :text
  end

  def down
    change_column :requests, :http_env, :string, length: 2048
  end
end

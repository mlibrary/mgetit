class HttpEnvTooSmall < ActiveRecord::Migration
  def up
    change_column :requests, :http_env, :text
  end

  def down
    change_column :requests, :http_env, :string, length: 2048
  end
end

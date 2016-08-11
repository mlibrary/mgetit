class StoreLargerUrls < ActiveRecord::Migration
  def up
    change_column :service_responses, :url, :text
  end

  def down
    change_column :service_responses, :url, :string
  end
end

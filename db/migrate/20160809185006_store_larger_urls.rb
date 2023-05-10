class StoreLargerUrls < ActiveRecord::Migration[4.2]
  def up
    change_column :service_responses, :url, :text
  end

  def down
    change_column :service_responses, :url, :string
  end
end

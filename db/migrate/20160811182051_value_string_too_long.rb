class ValueStringTooLong < ActiveRecord::Migration[4.2]
  def up
    remove_index :service_responses, name: "svc_resp_service_id"
    change_column :service_responses, :value_string, :text
    add_index :service_responses, [:service_id, :response_key, :value_string, :value_alt_string], name: "svc_resp_service_id", using: :btree, length: {value_string: 255}
  end

  def down
    change_column :service_responses, :value_string, :string, length: 255
  end
end

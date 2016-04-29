# This migration comes from umlaut (originally 2)
class UmlautAddServiceResponseIndex < ActiveRecord::Migration
  def up
    add_index "service_responses", ["request_id"]
  end

  def down
    remove_index "service_responses", ["request_id"]
  end
end

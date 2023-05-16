# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2016_08_11_182051) do

  create_table "clickthroughs", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "request_id", default: 0, null: false
    t.integer "service_response_id", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "click_created_idx"
    t.index ["request_id"], name: "click_req_id"
    t.index ["service_response_id"], name: "click_serv_resp_idx"
  end

  create_table "dispatched_services", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "request_id", default: 0, null: false
    t.string "service_id", default: "0", null: false
    t.datetime "updated_at", null: false
    t.text "exception_info"
    t.string "status", null: false
    t.datetime "created_at"
    t.index ["request_id", "service_id"], name: "dptch_request_id"
  end

  create_table "permalinks", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "referent_id", default: 0
    t.date "created_on", null: false
    t.text "context_obj_serialized"
    t.string "orig_rfr_id", limit: 256
    t.date "last_access"
    t.index ["referent_id"], name: "plink_referent_idx"
  end

  create_table "referent_values", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "referent_id", default: 0, null: false
    t.string "key_name", limit: 50, default: "", null: false
    t.text "value"
    t.string "normalized_value"
    t.boolean "metadata", default: false, null: false
    t.boolean "private_data", default: false, null: false
    t.datetime "created_at"
    t.index ["key_name", "normalized_value"], name: "by_name_and_normal_val"
    t.index ["referent_id", "key_name", "normalized_value"], name: "rft_val_referent_idx"
  end

  create_table "referents", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "atitle"
    t.string "title"
    t.string "issn", limit: 10
    t.string "isbn", limit: 13
    t.string "year", limit: 4
    t.string "volume", limit: 10
    t.datetime "created_at"
    t.index ["atitle", "title", "issn", "isbn", "year", "volume"], name: "rft_shortcut_idx"
    t.index ["isbn"], name: "index_referents_on_isbn"
    t.index ["issn", "year", "volume"], name: "by_issn"
    t.index ["title"], name: "index_referents_on_title"
    t.index ["volume"], name: "index_referents_on_volume"
    t.index ["year", "volume"], name: "by_year"
  end

  create_table "requests", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "session_id", limit: 100, default: "", null: false
    t.integer "referent_id", default: 0, null: false
    t.string "referrer_id"
    t.datetime "created_at", null: false
    t.string "client_ip_addr"
    t.boolean "client_ip_is_simulated"
    t.string "contextobj_fingerprint", limit: 32
    t.text "http_env"
    t.index ["client_ip_addr"], name: "index_requests_on_client_ip_addr"
    t.index ["contextobj_fingerprint"], name: "index_requests_on_contextobj_fingerprint"
    t.index ["created_at"], name: "req_created_at"
    t.index ["referent_id", "referrer_id"], name: "context_object_idx"
    t.index ["session_id"], name: "req_sess_idx"
  end

  create_table "service_responses", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "service_id", limit: 25, null: false
    t.string "response_key", default: ""
    t.text "value_string"
    t.string "value_alt_string"
    t.text "value_text"
    t.string "display_text"
    t.text "url"
    t.text "notes"
    t.text "service_data"
    t.datetime "created_at"
    t.string "service_type_value_name"
    t.integer "request_id"
    t.index ["request_id"], name: "index_service_responses_on_request_id"
    t.index ["service_id", "response_key", "value_string", "value_alt_string"], name: "svc_resp_service_id", length: { value_string: 255 }
  end

  create_table "sfx_urls", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "url"
    t.index ["url"], name: "index_sfx_urls_on_url"
  end

end

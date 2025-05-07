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

ActiveRecord::Schema[7.1].define(version: 2025_05_07_111140) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "locale"
    t.index ["record_type", "record_id", "name", "locale"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.integer "order_no", default: 0, null: false
    t.jsonb "name", default: {}
    t.string "complete_address", default: "", null: false
    t.string "phone1", default: "", null: false
    t.string "phone2", default: "", null: false
    t.string "fax", default: "", null: false
    t.string "email1", default: "", null: false
    t.string "email2", default: "", null: false
    t.string "longitude", default: "", null: false
    t.string "latitude", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "full_name", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role_id", default: 0, null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
  end

  create_table "articles", force: :cascade do |t|
    t.jsonb "title", default: {}
    t.jsonb "short_description", default: {}
    t.bigint "category_id"
    t.datetime "published_date"
    t.integer "status", default: 1, null: false
    t.string "video_url", default: "", null: false
    t.string "tags", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "slug", default: {}
    t.jsonb "meta_title", default: {}
    t.jsonb "meta_description", default: {}
    t.index ["category_id"], name: "index_articles_on_category_id"
    t.index ["slug"], name: "index_articles_on_slug", unique: true
    t.index ["title"], name: "index_articles_on_title", unique: true
  end

  create_table "banner_sections", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.integer "style", default: 0, null: false
    t.integer "size", default: 0, null: false
  end

  create_table "banners", force: :cascade do |t|
    t.integer "order_no", default: 0, null: false
    t.jsonb "title", default: {}
    t.jsonb "description", default: {}
    t.bigint "banner_section_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "orientation"
    t.index ["banner_section_id"], name: "index_banners_on_banner_section_id"
  end

  create_table "categories", force: :cascade do |t|
    t.jsonb "name", default: {}
  end

  create_table "events", force: :cascade do |t|
    t.jsonb "name", default: {}
    t.jsonb "short_description", default: {}
    t.jsonb "description", default: {}
    t.datetime "start_date"
    t.datetime "end_date"
    t.bigint "sport_id"
    t.jsonb "slug", default: {}
    t.index ["name"], name: "index_events_on_name", unique: true
    t.index ["slug"], name: "index_events_on_slug", unique: true
    t.index ["sport_id"], name: "index_events_on_sport_id"
  end

  create_table "facilities", force: :cascade do |t|
    t.jsonb "name", default: {}
    t.jsonb "short_description", default: {}
    t.jsonb "description", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "slug", default: {}
    t.index ["name"], name: "index_facilities_on_name", unique: true
    t.index ["slug"], name: "index_facilities_on_slug", unique: true
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "inquiries", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "company_name", default: "", null: false
    t.string "email", default: "", null: false
    t.string "phone", default: "", null: false
    t.string "subject", default: "", null: false
    t.string "message", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "promos", force: :cascade do |t|
    t.jsonb "name", default: {}
    t.jsonb "short_description", default: {}
    t.jsonb "description", default: {}
    t.datetime "start_date"
    t.datetime "end_date"
    t.bigint "sport_id"
    t.jsonb "slug", default: {}
    t.index ["name"], name: "index_promos_on_name", unique: true
    t.index ["slug"], name: "index_promos_on_slug", unique: true
    t.index ["sport_id"], name: "index_promos_on_sport_id"
  end

  create_table "questions", force: :cascade do |t|
    t.integer "order_no", default: 0, null: false
    t.jsonb "title", default: {}
    t.jsonb "description", default: {}
    t.string "section", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "description", default: "", null: false
  end

  create_table "sports", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.jsonb "short_description", default: {}
    t.jsonb "description", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug", default: ""
    t.index ["name"], name: "index_sports_on_name", unique: true
    t.index ["slug"], name: "index_sports_on_slug", unique: true
  end

  create_table "testimonials", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "email", default: "", null: false
    t.string "company_name", default: "", null: false
    t.string "comment", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "full_name", default: "", null: false
    t.string "phone", default: "", null: false
    t.date "dob"
    t.integer "gender", default: 0, null: false
    t.string "nationality", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end

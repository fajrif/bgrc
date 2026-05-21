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

ActiveRecord::Schema[7.1].define(version: 2026_05_20_102859) do
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

  create_table "add_ons", force: :cascade do |t|
    t.bigint "booking_id"
    t.bigint "item_id"
    t.integer "quantity", default: 1, null: false
    t.decimal "price", default: "0.0", null: false
    t.index ["booking_id"], name: "index_add_ons_on_booking_id"
    t.index ["item_id"], name: "index_add_ons_on_item_id"
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

  create_table "bookings", force: :cascade do |t|
    t.integer "user_id"
    t.integer "court_id"
    t.datetime "date"
    t.datetime "end_date"
    t.integer "duration", default: 1, null: false
    t.integer "status", default: 0, null: false
    t.string "notes"
    t.decimal "price", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "court_type"
    t.integer "class_type", default: 0, null: false
    t.integer "coach_id"
    t.decimal "price_coach", default: "0.0", null: false
    t.decimal "total_price", default: "0.0", null: false
    t.string "order_id", default: "", null: false
    t.integer "group_class_id"
    t.integer "pax", default: 0, null: false
    t.datetime "expires_at"
    t.integer "class_credit_purchase_id"
    t.integer "reschedule_count", default: 0, null: false
    t.boolean "refunded", default: false, null: false
    t.index ["court_id"], name: "index_bookings_on_court_id"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "business_hours", force: :cascade do |t|
    t.integer "court_id", default: 0, null: false
    t.integer "day_code", default: 0, null: false
    t.string "day_name", default: "", null: false
    t.string "open", default: "06:00", null: false
    t.string "close", default: "22:00", null: false
    t.index ["court_id"], name: "index_business_hours_on_court_id"
  end

  create_table "categories", force: :cascade do |t|
    t.jsonb "name", default: {}
  end

  create_table "class_credit_purchases", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_class_id", null: false
    t.integer "sessions_count", default: 1, null: false
    t.decimal "price_paid", precision: 15, scale: 2, default: "0.0"
    t.datetime "purchase_date"
    t.integer "status", default: 0, null: false
    t.string "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "expires_at"
    t.datetime "initial_session_date"
    t.integer "pax", default: 1, null: false
    t.index ["order_id"], name: "index_class_credit_purchases_on_order_id", unique: true
    t.index ["user_id", "group_class_id"], name: "index_class_credit_purchases_on_user_id_and_group_class_id"
  end

  create_table "coaches", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "email", default: "", null: false
    t.string "phone", default: "", null: false
    t.integer "gender", default: 1, null: false
    t.decimal "price", default: "0.0", null: false
  end

  create_table "costs", force: :cascade do |t|
    t.integer "court_id", default: 0, null: false
    t.integer "day_code", default: 0, null: false
    t.string "day_name", default: "", null: false
    t.string "start_time", default: "16:00", null: false
    t.string "end_time", default: "22:00", null: false
    t.decimal "price", default: "0.0", null: false
    t.index ["court_id"], name: "index_costs_on_court_id"
  end

  create_table "court_types", force: :cascade do |t|
    t.string "name", default: "", null: false
  end

  create_table "courts", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.bigint "sport_id"
    t.integer "status", default: 0, null: false
    t.integer "min_duration", default: 1, null: false
    t.decimal "price", default: "0.0", null: false
    t.string "location", default: "", null: false
    t.jsonb "info", default: {}
    t.jsonb "instructions", default: {}
    t.jsonb "description", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "court_type_id"
    t.index ["sport_id"], name: "index_courts_on_sport_id"
  end

  create_table "event_rsvps", force: :cascade do |t|
    t.bigint "recurring_event_id", null: false
    t.string "full_name"
    t.string "email"
    t.string "phone"
    t.date "dob"
    t.string "gender"
    t.text "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recurring_event_id"], name: "index_event_rsvps_on_recurring_event_id"
  end

  create_table "events", force: :cascade do |t|
    t.jsonb "name", default: {}
    t.jsonb "short_description", default: {}
    t.jsonb "description", default: {}
    t.datetime "start_date"
    t.datetime "end_date"
    t.bigint "sport_id"
    t.jsonb "slug", default: {}
    t.integer "featured", default: 0, null: false
    t.integer "capacity", default: 0
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

  create_table "group_class_packs", force: :cascade do |t|
    t.bigint "group_class_id", null: false
    t.integer "sessions_count", null: false
    t.decimal "price", precision: 12, scale: 2, null: false
    t.string "label"
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "validity_months"
    t.index ["group_class_id"], name: "index_group_class_packs_on_group_class_id"
  end

  create_table "group_class_registrations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_class_id", null: false
    t.bigint "class_credit_purchase_id"
    t.bigint "court_id", null: false
    t.datetime "session_date", null: false
    t.integer "pax", default: 1, null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["class_credit_purchase_id"], name: "index_group_class_registrations_on_class_credit_purchase_id"
    t.index ["court_id"], name: "index_group_class_registrations_on_court_id"
    t.index ["group_class_id"], name: "index_group_class_registrations_on_group_class_id"
    t.index ["user_id"], name: "index_group_class_registrations_on_user_id"
  end

  create_table "group_class_schedules", force: :cascade do |t|
    t.bigint "group_class_id", null: false
    t.bigint "court_id", null: false
    t.integer "day_of_week", null: false
    t.string "start_time", null: false
    t.string "end_time", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["court_id"], name: "index_group_class_schedules_on_court_id"
    t.index ["group_class_id"], name: "index_group_class_schedules_on_group_class_id"
  end

  create_table "group_classes", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.integer "min_duration", default: 1, null: false
    t.integer "min_pax", default: 1, null: false
    t.integer "max_pax", default: 1, null: false
    t.integer "status", default: 1, null: false
    t.decimal "price", default: "0.0", null: false
    t.decimal "price_pax", default: "0.0", null: false
    t.string "notes"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order_no"
    t.string "category"
    t.integer "sport_id"
    t.boolean "is_prescheduled", default: false
    t.integer "min_pack_sessions", default: 1
    t.integer "max_pack_sessions", default: 1
    t.string "calendar_color", default: "#0d6efd"
    t.integer "credit_validity_months"
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

  create_table "items", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.decimal "price", default: "0.0", null: false
  end

  create_table "packages", force: :cascade do |t|
    t.jsonb "name", default: {}
    t.jsonb "short_description", default: {}
    t.jsonb "description", default: {}
    t.datetime "start_date"
    t.datetime "end_date"
    t.bigint "sport_id"
    t.jsonb "slug", default: {}
    t.index ["name"], name: "index_packages_on_name", unique: true
    t.index ["slug"], name: "index_packages_on_slug", unique: true
    t.index ["sport_id"], name: "index_packages_on_sport_id"
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

  create_table "providers", force: :cascade do |t|
    t.bigint "user_id"
    t.string "provider"
    t.string "uid"
    t.string "access_token"
    t.string "access_secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_providers_on_user_id"
  end

  create_table "purchases", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "productable_type"
    t.bigint "productable_id"
    t.string "token"
    t.string "status_code", default: "000"
    t.string "status_message", default: "Initialize Object"
    t.string "transaction_id"
    t.string "masked_card"
    t.string "order_id"
    t.string "gross_amount"
    t.string "payment_type"
    t.string "transaction_time"
    t.string "transaction_status"
    t.string "fraud_status"
    t.string "approval_code"
    t.string "bank"
    t.string "card_type"
    t.string "save_token_id"
    t.string "saved_token_id_expired_at"
    t.string "channel_response_code"
    t.string "channel_response_message"
    t.index ["productable_type", "productable_id"], name: "index_purchases_on_productable"
    t.index ["user_id"], name: "index_purchases_on_user_id"
  end

  create_table "questions", force: :cascade do |t|
    t.integer "order_no", default: 0, null: false
    t.jsonb "title", default: {}
    t.jsonb "description", default: {}
    t.string "section", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recurring_event_courts", force: :cascade do |t|
    t.bigint "recurring_event_id", null: false
    t.bigint "court_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["court_id"], name: "index_recurring_event_courts_on_court_id"
    t.index ["recurring_event_id", "court_id"], name: "index_rec_event_courts_unique", unique: true
    t.index ["recurring_event_id"], name: "index_recurring_event_courts_on_recurring_event_id"
  end

  create_table "recurring_events", force: :cascade do |t|
    t.string "title"
    t.integer "day_of_week"
    t.string "start_time"
    t.string "end_time"
    t.date "specific_date"
    t.text "description"
    t.integer "capacity", default: 0
    t.text "short_description"
    t.boolean "active", default: true, null: false
    t.boolean "hide", default: false, null: false
    t.date "end_date"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "description", default: "", null: false
  end

  create_table "snippets", force: :cascade do |t|
    t.string "key", null: false
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_snippets_on_key", unique: true
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
    t.datetime "remember_created_at"
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

  create_table "wellnesses", force: :cascade do |t|
    t.jsonb "name", default: {}
    t.jsonb "short_description", default: {}
    t.jsonb "description", default: {}
    t.jsonb "slug", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_wellnesses_on_name", unique: true
    t.index ["slug"], name: "index_wellnesses_on_slug", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "event_rsvps", "events", column: "recurring_event_id"
  add_foreign_key "group_class_packs", "group_classes"
  add_foreign_key "group_class_registrations", "class_credit_purchases"
  add_foreign_key "group_class_registrations", "courts"
  add_foreign_key "group_class_registrations", "group_classes"
  add_foreign_key "group_class_registrations", "users"
  add_foreign_key "group_class_schedules", "courts"
  add_foreign_key "group_class_schedules", "group_classes"
  add_foreign_key "recurring_event_courts", "courts"
  add_foreign_key "recurring_event_courts", "recurring_events"
end

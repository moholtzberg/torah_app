# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171209150043) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.string   "trackable_type"
    t.integer  "trackable_id"
    t.string   "owner_type"
    t.integer  "owner_id"
    t.string   "key"
    t.text     "parameters"
    t.string   "recipient_type"
    t.integer  "recipient_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree
  end

  create_table "chatrooms", force: :cascade do |t|
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "organization_id"
    t.index ["organization_id"], name: "index_chatrooms_on_organization_id", using: :btree
  end

  create_table "devices", force: :cascade do |t|
    t.string   "endpoint"
    t.string   "p256dh"
    t.string   "auth"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_devices_on_user_id", using: :btree
  end

  create_table "friendships", force: :cascade do |t|
    t.string   "friendable_type"
    t.integer  "friendable_id"
    t.integer  "friend_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "blocker_id"
    t.integer  "status"
  end

  create_table "interests", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "subject_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subject_id"], name: "index_interests_on_subject_id", using: :btree
    t.index ["user_id"], name: "index_interests_on_user_id", using: :btree
  end

  create_table "lessons", force: :cascade do |t|
    t.text      "message"
    t.integer   "sender_id"
    t.integer   "receiver_id"
    t.integer   "subject_id"
    t.datetime  "confirmed_at"
    t.datetime  "created_at",                  null: false
    t.datetime  "updated_at",                  null: false
    t.boolean   "recurring"
    t.tstzrange "time"
    t.boolean   "private",      default: true
    t.index ["receiver_id"], name: "index_lessons_on_receiver_id", using: :btree
    t.index ["sender_id"], name: "index_lessons_on_sender_id", using: :btree
    t.index ["subject_id"], name: "index_lessons_on_subject_id", using: :btree
  end

  create_table "memberships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "organization_id"
    t.integer  "role",            default: 0
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.datetime "confirmed_at"
    t.index ["organization_id"], name: "index_memberships_on_organization_id", using: :btree
    t.index ["user_id"], name: "index_memberships_on_user_id", using: :btree
  end

  create_table "messages", force: :cascade do |t|
    t.string   "body"
    t.integer  "user_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "chatroom_id"
    t.integer  "type_of",     default: 0
    t.index ["chatroom_id"], name: "index_messages_on_chatroom_id", using: :btree
    t.index ["user_id"], name: "index_messages_on_user_id", using: :btree
  end

  create_table "notifications", force: :cascade do |t|
    t.text     "message"
    t.integer  "user_id"
    t.string   "link"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id", using: :btree
  end

  create_table "organizations", force: :cascade do |t|
    t.string   "name"
    t.string   "headline"
    t.text     "description"
    t.string   "thumbnail"
    t.datetime "confirmed_at"
    t.integer  "founder_id"
    t.string   "banner"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["founder_id"], name: "index_organizations_on_founder_id", using: :btree
  end

  create_table "participatings", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "chatroom_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["chatroom_id"], name: "index_participatings_on_chatroom_id", using: :btree
    t.index ["user_id"], name: "index_participatings_on_user_id", using: :btree
  end

  create_table "posts", force: :cascade do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "user_id"
    t.integer  "organization_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["organization_id"], name: "index_posts_on_organization_id", using: :btree
    t.index ["user_id"], name: "index_posts_on_user_id", using: :btree
  end

  create_table "subjects", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "parent_id"
    t.text     "description"
    t.text     "headline"
    t.boolean  "featured"
    t.string   "thumbnail"
    t.string   "banner"
    t.index ["parent_id"], name: "index_subjects_on_parent_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string    "email",                  default: "",      null: false
    t.string    "encrypted_password",     default: "",      null: false
    t.string    "reset_password_token"
    t.datetime  "reset_password_sent_at"
    t.datetime  "remember_created_at"
    t.integer   "sign_in_count",          default: 0,       null: false
    t.datetime  "current_sign_in_at"
    t.datetime  "last_sign_in_at"
    t.string    "current_sign_in_ip"
    t.string    "last_sign_in_ip"
    t.string    "confirmation_token"
    t.datetime  "confirmed_at"
    t.datetime  "confirmation_sent_at"
    t.string    "unconfirmed_email"
    t.integer   "failed_attempts",        default: 0,       null: false
    t.string    "unlock_token"
    t.datetime  "locked_at"
    t.datetime  "created_at",                               null: false
    t.datetime  "updated_at",                               null: false
    t.string    "name"
    t.string    "avatar"
    t.integer   "status",                 default: 0
    t.boolean   "admin",                  default: false
    t.string    "country"
    t.string    "state"
    t.string    "city"
    t.boolean   "moderator"
    t.boolean   "verified"
    t.string    "time_zone",              default: "UTC"
    t.tstzrange "availability",                                          array: true
    t.string    "provider",               default: "email", null: false
    t.string    "uid",                    default: "",      null: false
    t.string    "tokens"
    t.string    "language"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree
  end

  add_foreign_key "interests", "subjects"
  add_foreign_key "interests", "users"
  add_foreign_key "lessons", "subjects"
  add_foreign_key "messages", "users"
  add_foreign_key "participatings", "chatrooms"
  add_foreign_key "participatings", "users"
end

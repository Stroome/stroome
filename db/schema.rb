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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110506093927) do

  create_table "activities", :force => true do |t|
    t.integer  "subject_id"
    t.string   "subject_type"
    t.string   "event"
    t.integer  "object_id"
    t.string   "object_type"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admins", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true
  add_index "admins", ["username"], :name => "index_admins_on_username", :unique => true

  create_table "clips", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "duration"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "video_id"
    t.string   "thumbnail_url"
    t.integer  "total_used"
    t.integer  "total_shared"
    t.integer  "total_likes"
    t.integer  "total_rating_votes"
    t.integer  "rating"
    t.integer  "total_views"
    t.string   "tags"
  end

  create_table "clips_projects", :id => false, :force => true do |t|
    t.integer "clip_id"
    t.integer "project_id"
  end

  create_table "clips_topics", :id => false, :force => true do |t|
    t.integer "topic_id"
    t.integer "clip_id"
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.string   "body"
    t.integer  "parent_id"
    t.integer  "project_id"
    t.integer  "clip_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
  end

  create_table "group_members", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "membership"
    t.string   "location"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picture"
  end

  create_table "groups_topics", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "topic_id"
  end

  create_table "impressions", :force => true do |t|
    t.string   "impressionable_type"
    t.integer  "impressionable_id"
    t.integer  "user_id"
    t.string   "controller_name"
    t.string   "action_name"
    t.string   "view_name"
    t.string   "request_hash"
    t.string   "session_hash"
    t.string   "ip_address"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "impressions", ["controller_name", "action_name", "ip_address"], :name => "controlleraction_ip_index"
  add_index "impressions", ["controller_name", "action_name", "request_hash"], :name => "controlleraction_request_index"
  add_index "impressions", ["controller_name", "action_name", "session_hash"], :name => "controlleraction_session_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "ip_address"], :name => "poly_ip_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "request_hash"], :name => "poly_request_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "session_hash"], :name => "poly_session_index"
  add_index "impressions", ["user_id"], :name => "index_impressions_on_user_id"

  create_table "inbin_clip_refs", :force => true do |t|
    t.integer "inbin_clip_owner_id"
    t.string  "inbin_clip_owner_type"
    t.integer "clip_id"
  end

  create_table "join_requests", :force => true do |t|
    t.integer  "sender_id"
    t.string   "join_type"
    t.integer  "receiver_id"
    t.string   "receiver_type"
    t.integer  "joinable_id"
    t.string   "joinable_type"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "external_id"
  end

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.string   "description"
    t.string   "status"
    t.string   "token"
    t.string   "prompt_actions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.string   "content_type"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "potential_users", :force => true do |t|
    t.string   "email"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_groups", :force => true do |t|
    t.integer  "project_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_invitations", :force => true do |t|
    t.integer  "project_id"
    t.integer  "sender_id"
    t.string   "status"
    t.string   "token"
    t.integer  "receiver_id"
    t.string   "receiver_email"
    t.string   "receiver_name"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_members", :force => true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "duration"
    t.string   "tags"
    t.string   "location"
    t.string   "editor_type"
    t.string   "visibility"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_members"
    t.integer  "total_remixed"
    t.integer  "total_shared"
    t.integer  "total_likes"
    t.integer  "total_views"
    t.integer  "total_rating_votes"
    t.integer  "rating"
    t.string   "thumbnail_url"
    t.string   "video_id"
    t.integer  "uiconf_kcw_id"
    t.integer  "uiconf_kse_id"
    t.integer  "uiconf_kae_id"
    t.integer  "remixed_from_id"
    t.datetime "video_updated_at"
  end

  create_table "projects_topics", :id => false, :force => true do |t|
    t.integer "project_id"
    t.integer "topic_id"
  end

  create_table "rates", :force => true do |t|
    t.integer  "rater_id"
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.integer  "stars",         :null => false
    t.string   "dimension"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rates", ["rateable_id", "rateable_type"], :name => "index_rates_on_rateable_id_and_rateable_type"
  add_index "rates", ["rater_id"], :name => "index_rates_on_rater_id"

  create_table "settings", :force => true do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topics", :force => true do |t|
    t.string "code"
    t.string "label"
  end

  create_table "topics_users", :id => false, :force => true do |t|
    t.integer "topic_id"
    t.integer "user_id"
  end

  create_table "translations", :force => true do |t|
    t.string   "locale"
    t.string   "key"
    t.text     "value"
    t.text     "interpolations"
    t.boolean  "is_proc",        :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_followings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "following_id"
    t.string   "following_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_notifications", :force => true do |t|
    t.integer  "user_id"
    t.string   "notify_type"
    t.string   "status"
    t.string   "title"
    t.string   "description"
    t.integer  "actionable_id"
    t.string   "actionable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email",                                 :default => "", :null => false
    t.string   "password"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "location"
    t.text     "about_me"
    t.boolean  "is_public"
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picture"
    t.integer  "total_views"
    t.integer  "rating"
    t.integer  "total_projects"
    t.integer  "total_clips"
    t.integer  "times_projects_remixed"
    t.integer  "total_likes"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end

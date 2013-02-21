# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20130220224540) do

  create_table "booklists", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "slug"
    t.integer  "school_id"
  end

  add_index "booklists", ["slug"], :name => "index_booklists_on_slug", :unique => true

  create_table "books", :force => true do |t|
    t.string   "title"
    t.string   "author"
    t.string   "isbn_10"
    t.string   "edition"
    t.string   "requirement"
    t.string   "asin"
    t.datetime "created_at",                                                              :null => false
    t.datetime "updated_at",                                                              :null => false
    t.decimal  "bookstore_new_price",                       :precision => 6, :scale => 2
    t.decimal  "bookstore_new_rental_price",                :precision => 6, :scale => 2
    t.decimal  "bookstore_used_price",                      :precision => 6, :scale => 2
    t.decimal  "bookstore_used_rental_price",               :precision => 6, :scale => 2
    t.string   "ean",                         :limit => 13
    t.integer  "section_id"
    t.string   "notes"
    t.string   "link"
  end

  add_index "books", ["ean"], :name => "index_books_on_ean"
  add_index "books", ["section_id"], :name => "index_books_on_section_id"

  create_table "courses", :force => true do |t|
    t.string   "department"
    t.string   "number"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "booklist_id"
    t.string   "school_unique_id"
  end

  add_index "courses", ["booklist_id"], :name => "index_courses_on_booklist_id"

  create_table "offers", :force => true do |t|
    t.string   "condition"
    t.string   "vendor"
    t.decimal  "price",              :precision => 6, :scale => 2
    t.decimal  "decimal",            :precision => 6, :scale => 2
    t.string   "vendor_book_id"
    t.string   "vendor_offer_id"
    t.string   "detailed_condition"
    t.string   "availability"
    t.string   "shipping_time"
    t.string   "comments"
    t.string   "link"
    t.integer  "book_id"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
  end

  create_table "pages", :force => true do |t|
    t.integer  "booklist_id"
    t.text     "html"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "pages", ["booklist_id"], :name => "index_pages_on_booklist_id"

  create_table "schools", :force => true do |t|
    t.string   "name"
    t.string   "slug"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.string   "primary_color",   :limit => 6
    t.string   "secondary_color", :limit => 6
    t.string   "user_id_label"
    t.string   "bookstore_name"
  end

  add_index "schools", ["slug"], :name => "index_schools_on_slug", :unique => true

  create_table "sections", :force => true do |t|
    t.string   "school_unique_id"
    t.integer  "course_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "instructor"
  end

  add_index "sections", ["course_id"], :name => "index_sections_on_course_id"

end

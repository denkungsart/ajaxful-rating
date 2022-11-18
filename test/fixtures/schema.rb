ActiveRecord::Schema.define do
  create_table "cars", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rates", force: true do |t|
    t.integer  "rater_id"
    t.string   "rater_type"
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.integer  "stars", null: false
    t.string   "dimension"
  end

  add_index "rates", %w(rateable_id rateable_type), name: "index_rates_on_rateable_id_and_rateable_type"
  add_index "rates", %w(rater_id rater_type), name: "index_rates_on_rater_id_and_rater_type"

  create_table "users", force: true do |t|
    t.string   "name"
  end

  create_table "rentals", force: true do |t|
    t.string   "name"
  end
end

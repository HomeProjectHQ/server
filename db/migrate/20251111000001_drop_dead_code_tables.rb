class DropDeadCodeTables < ActiveRecord::Migration[8.0]
  def change
    # Drop picks table (replaced by featured_items)
    drop_table :picks, if_exists: true do |t|
      t.bigint "profile_id", null: false
      t.string "pickable_type", null: false
      t.bigint "pickable_id", null: false
      t.string "caption"
      t.jsonb "reasoning", default: {}
      t.jsonb "context_snapshot", default: {}
      t.datetime "generated_at"
      t.datetime "expires_at"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["pickable_type", "pickable_id"], name: "index_picks_on_pickable"
      t.index ["profile_id", "generated_at"], name: "index_picks_on_profile_id_and_generated_at"
      t.index ["profile_id", "pickable_type", "pickable_id"], name: "index_picks_on_profile_id_and_pickable_type_and_pickable_id"
      t.index ["profile_id"], name: "index_picks_on_profile_id"
    end
    
    # Drop orphaned media table (no model or controller exists)
    drop_table :media, if_exists: true do |t|
      t.string "title"
      t.text "description"
      t.string "status"
      t.string "hls_path"
      t.integer "duration"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
  end
end



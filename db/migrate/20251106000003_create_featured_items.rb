class CreateFeaturedItems < ActiveRecord::Migration[8.0]
  def change
    create_table :featured_items do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :featurable, polymorphic: true, null: false
      t.string :caption
      t.jsonb :placements, default: [], null: false
      t.jsonb :reasoning, default: {}
      t.jsonb :context_snapshot, default: {}
      t.datetime :generated_at
      t.datetime :expires_at

      t.timestamps
    end

    add_index :featured_items, [:profile_id, :generated_at]
    add_index :featured_items, [:profile_id, :featurable_type, :featurable_id]
    add_index :featured_items, :placements, using: :gin
  end
end


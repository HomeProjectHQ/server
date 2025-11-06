class CreatePicks < ActiveRecord::Migration[8.0]
  def change
    create_table :picks do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :pickable, polymorphic: true, null: false
      t.string :caption
      t.jsonb :reasoning, default: {}
      t.jsonb :context_snapshot, default: {}
      t.datetime :generated_at
      t.datetime :expires_at

      t.timestamps
    end

    add_index :picks, [:profile_id, :generated_at]
    add_index :picks, [:profile_id, :pickable_type, :pickable_id]
  end
end


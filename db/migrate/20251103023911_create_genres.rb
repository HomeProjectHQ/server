class CreateGenres < ActiveRecord::Migration[8.0]
  def change
    create_table :genres do |t|
      t.integer :tmdb_id
      t.string :name

      t.timestamps
    end
    add_index :genres, :tmdb_id, unique: true
  end
end

class CreateMovies < ActiveRecord::Migration[8.0]
  def change
    create_table :movies do |t|
      t.string :title
      t.integer :tmdb_id
      t.integer :year
      t.text :overview
      t.string :poster_path
      t.string :backdrop_path
      t.integer :runtime
      t.decimal :rating
      t.text :genres
      t.string :file_path
      t.bigint :file_size

      t.timestamps
    end
  end
end

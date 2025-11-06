class CreateTvShows < ActiveRecord::Migration[8.0]
  def change
    create_table :tv_shows do |t|
      t.string :title
      t.integer :tvdb_id
      t.integer :tmdb_id
      t.integer :year
      t.text :overview
      t.string :poster_path
      t.string :backdrop_path
      t.string :status
      t.string :network
      t.text :genres

      t.timestamps
    end
  end
end

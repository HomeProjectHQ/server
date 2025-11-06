class RemoveGenresColumnFromMoviesAndTvShows < ActiveRecord::Migration[8.0]
  def change
    remove_column :movies, :genres, :jsonb
    remove_column :tv_shows, :genres, :jsonb
  end
end

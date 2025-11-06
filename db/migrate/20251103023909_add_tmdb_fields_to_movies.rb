class AddTmdbFieldsToMovies < ActiveRecord::Migration[8.0]
  def change
    add_column :movies, :imdb_id, :string
    add_column :movies, :tagline, :text
    add_column :movies, :vote_average, :decimal
    add_column :movies, :vote_count, :integer
    add_column :movies, :release_date, :date
    add_column :movies, :popularity, :decimal
    add_column :movies, :original_language, :string
    add_column :movies, :original_title, :string
    add_column :movies, :budget, :bigint
    add_column :movies, :revenue, :bigint
    add_column :movies, :homepage, :string
  end
end

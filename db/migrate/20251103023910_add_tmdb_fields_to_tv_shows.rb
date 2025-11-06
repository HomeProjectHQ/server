class AddTmdbFieldsToTvShows < ActiveRecord::Migration[8.0]
  def change
    add_column :tv_shows, :tagline, :text
    add_column :tv_shows, :vote_average, :decimal
    add_column :tv_shows, :vote_count, :integer
    add_column :tv_shows, :first_air_date, :date
    add_column :tv_shows, :last_air_date, :date
    add_column :tv_shows, :popularity, :decimal
    add_column :tv_shows, :original_language, :string
    add_column :tv_shows, :original_name, :string
    add_column :tv_shows, :homepage, :string
    add_column :tv_shows, :number_of_episodes, :integer
    add_column :tv_shows, :number_of_seasons, :integer
    add_column :tv_shows, :in_production, :boolean
    add_column :tv_shows, :type, :string
  end
end

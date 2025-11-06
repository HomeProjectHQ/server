class Genre < ApplicationRecord
  has_many :movie_genres, dependent: :destroy
  has_many :movies, through: :movie_genres
  
  has_many :tv_show_genres, dependent: :destroy
  has_many :tv_shows, through: :tv_show_genres
  
  validates :tmdb_id, presence: true, uniqueness: true
  validates :name, presence: true
  
  # Find or create genre from TMDB data
  def self.from_tmdb(tmdb_genre)
    find_or_create_by(tmdb_id: tmdb_genre['id']) do |genre|
      genre.name = tmdb_genre['name']
    end
  end
end

class TvShow < ApplicationRecord
  # Associations
  has_many :tv_seasons, dependent: :destroy
  has_many :tv_episodes, through: :tv_seasons
  
  has_many :profile_tv_shows, dependent: :destroy
  has_many :profiles, through: :profile_tv_shows
  
  # Genre associations
  has_many :tv_show_genres, dependent: :destroy
  has_many :genres, through: :tv_show_genres
  
  # Validations
  validates :title, presence: true
  
  # Scopes
  scope :by_genre, ->(genre_name) { joins(:genres).where(genres: { name: genre_name }) }
  scope :recent, -> { order(first_air_date: :desc) }
  scope :popular, -> { order(popularity: :desc) }
  scope :highly_rated, -> { where('vote_average >= ?', 7.0).order(vote_average: :desc) }
  scope :currently_airing, -> { where(in_production: true) }
  scope :ended, -> { where(in_production: false) }
  
  # Methods
  def poster_url(size = 'w500')
    return nil unless poster_path
    "https://image.tmdb.org/t/p/#{size}#{poster_path}"
  end
  
  def backdrop_url(size = 'w1280')
    return nil unless backdrop_path
    "https://image.tmdb.org/t/p/#{size}#{backdrop_path}"
  end
end

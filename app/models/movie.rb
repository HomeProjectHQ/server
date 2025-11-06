class Movie < ApplicationRecord
  include Streamable
  
  # Profile associations
  has_many :profile_movies, dependent: :destroy
  has_many :profiles, through: :profile_movies
  
  # Genre associations
  has_many :movie_genres, dependent: :destroy
  has_many :genres, through: :movie_genres
  
  # Watch progress tracking
  has_many :watch_progresses, as: :watchable, dependent: :destroy
  
  # Validations
  validates :title, presence: true
  validates :file_path, presence: true, uniqueness: true
  
  # Scopes
  scope :by_year, ->(year) { where(year: year) }
  scope :by_genre, ->(genre_name) { joins(:genres).where(genres: { name: genre_name }) }
  scope :recent, -> { order(created_at: :desc) }
  scope :ready_to_stream, -> { where(status: 'ready').where.not(hls_path: nil) }
  scope :popular, -> { order(popularity: :desc) }
  scope :highly_rated, -> { where('vote_average >= ?', 7.0).order(vote_average: :desc) }
  
  # Methods
  def poster_url(size = 'w500')
    return nil unless poster_path
    "https://image.tmdb.org/t/p/#{size}#{poster_path}"
  end
  
  def backdrop_url(size = 'w1280')
    return nil unless backdrop_path
    "https://image.tmdb.org/t/p/#{size}#{backdrop_path}"
  end
  
  # Get a random movie recommendation (excluding this movie)
  # Returns nil if no other ready movies exist
  # Future: Replace with ML-based personalized recommendations
  def recommended_movie
    Movie
      .ready_to_stream
      .where.not(id: id)
      .order(Arel.sql('RANDOM()'))
      .limit(1)
      .first
  end
end

class Profile < ApplicationRecord
  # Associations for media library
  has_many :profile_movies, dependent: :destroy
  has_many :movies, through: :profile_movies
  
  has_many :profile_tv_shows, dependent: :destroy
  has_many :tv_shows, through: :profile_tv_shows
  
  has_many :profile_songs, dependent: :destroy
  has_many :songs, through: :profile_songs
  
  # Watch progress tracking
  has_many :watch_progresses, dependent: :destroy
  
  # Featured items (personalized recommendations)
  has_many :featured_items, dependent: :destroy
  
  # Available colors for profiles
  COLORS = %w[red blue green yellow purple orange pink teal indigo cyan amber lime emerald sky violet rose].freeze
  
  # Validations
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :color, inclusion: { in: COLORS, message: "%{value} is not a valid color" }, allow_nil: true
  
  # Watch progress methods
  
  # Get continue watching across all media types
  def continue_watching(limit: 10)
    watch_progresses.in_progress.recent.limit(limit)
  end
  
  # Get most recent episode watched for a TV show
  def latest_episode_for(tv_show)
    episode_ids = tv_show.tv_episodes.pluck(:id)
    
    watch_progresses
      .for_episodes
      .where(watchable_id: episode_ids)
      .recent
      .first
      &.watchable
  end
  
  # Get next unwatched episode for a TV show
  def next_episode_for(tv_show)
    latest = latest_episode_for(tv_show)
    
    if latest.nil?
      # Never watched, return first episode of first season
      tv_show.tv_episodes
        .joins(:tv_season)
        .order('tv_seasons.season_number ASC, tv_episodes.episode_number ASC')
        .first
    elsif latest.completed
      # Completed latest, find next episode
      tv_show.tv_episodes
        .joins(:tv_season)
        .where("(tv_seasons.season_number > ?) OR (tv_seasons.season_number = ? AND tv_episodes.episode_number > ?)", 
               latest.tv_season.season_number, 
               latest.tv_season.season_number, 
               latest.episode_number)
        .order('tv_seasons.season_number ASC, tv_episodes.episode_number ASC')
        .first
    else
      # Still watching, return same episode
      latest
    end
  end
  
  # Get or initialize progress for any media
  def progress_for(media)
    watch_progresses.find_or_initialize_by(watchable: media)
  end
end

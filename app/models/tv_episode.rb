class TvEpisode < ApplicationRecord
  include Streamable
  
  belongs_to :tv_season
  has_one :tv_show, through: :tv_season
  
  # Watch progress tracking
  has_many :watch_progresses, as: :watchable, dependent: :destroy
  
  validates :episode_number, presence: true
  validates :title, presence: true
  validates :file_path, presence: true, uniqueness: true
  validates :tv_season_id, uniqueness: { scope: :episode_number }
  
  def still_url(size = 'w300')
    return nil unless still_path
    "https://image.tmdb.org/t/p/#{size}#{still_path}"
  end
  
  # Helper to get season number
  def season_number
    tv_season&.season_number
  end
  
  # Find the next episode in the same TV show
  # Returns nil if this is the last episode
  def next_episode
    TvEpisode
      .joins(:tv_season)
      .where(tv_season: { tv_show_id: tv_show.id })
      .where(
        "(tv_season.season_number > ?) OR (tv_season.season_number = ? AND tv_episodes.episode_number > ?)",
        season_number,
        season_number,
        episode_number
      )
      .order('tv_season.season_number ASC, tv_episodes.episode_number ASC')
      .first
  end
end

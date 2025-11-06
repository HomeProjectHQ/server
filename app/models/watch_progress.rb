class WatchProgress < ApplicationRecord
  belongs_to :profile
  belongs_to :watchable, polymorphic: true
  
  # Validations
  validates :profile_id, uniqueness: { scope: [:watchable_type, :watchable_id] }
  validates :position_seconds, numericality: { greater_than_or_equal_to: 0 }
  
  # Scopes
  scope :recent, -> { order(last_watched_at: :desc) }
  scope :in_progress, -> { where(completed: false).where("position_seconds > 0") }
  scope :completed, -> { where(completed: true) }
  scope :for_episodes, -> { where(watchable_type: 'TvEpisode') }
  scope :for_movies, -> { where(watchable_type: 'Movie') }
  scope :for_songs, -> { where(watchable_type: 'Song') }
  
  # Helper method to update progress
  def update_progress(position, duration)
    # Increment watch count if user restarted from beginning
    self.watch_count ||= 0
    self.watch_count += 1 if position_seconds_previously_was.to_i > position && position < 30
    
    self.position_seconds = position
    self.duration_seconds = duration
    self.completed = (position.to_f / duration) >= 0.90 if duration && duration > 0
    self.last_watched_at = Time.current
    save!
  end
  
  # Calculate progress percentage
  def progress_percentage
    return 0 unless duration_seconds && duration_seconds > 0
    ((position_seconds.to_f / duration_seconds) * 100).round(2)
  end
end


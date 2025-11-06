class Pick < ApplicationRecord
  belongs_to :profile
  belongs_to :pickable, polymorphic: true
  
  # Validations
  validates :profile, presence: true
  validates :pickable, presence: true
  validates :caption, presence: true
  validates :generated_at, presence: true
  
  # Scopes
  scope :current, -> { where('expires_at IS NULL OR expires_at > ?', Time.current).order(generated_at: :desc) }
  scope :recent, -> { order(generated_at: :desc) }
  scope :for_profile, ->(profile) { where(profile: profile) }
  scope :movies, -> { where(pickable_type: 'Movie') }
  scope :tv_episodes, -> { where(pickable_type: 'TvEpisode') }
  scope :tv_shows, -> { where(pickable_type: 'TvShow') }
  
  # Get the current active pick for a profile
  def self.current_for(profile)
    for_profile(profile).current.first
  end
  
  # Check if this pick is still valid/current
  def current?
    expires_at.nil? || expires_at > Time.current
  end
  
  # Mark this pick as expired
  def expire!
    update(expires_at: Time.current)
  end
end


class FeaturedItem < ApplicationRecord
  belongs_to :profile
  belongs_to :featurable, polymorphic: true
  
  # Validations
  validates :profile, presence: true
  validates :featurable, presence: true
  validates :caption, presence: true
  validates :generated_at, presence: true
  validates :placements, presence: true
  
  # Scopes
  scope :current, -> { where('expires_at IS NULL OR expires_at > ?', Time.current).order(generated_at: :desc) }
  scope :recent, -> { order(generated_at: :desc) }
  scope :for_profile, ->(profile) { where(profile: profile) }
  scope :for_placement, ->(placement) { where("placements @> ?", [placement].to_json) }
  scope :for_any_placement, ->(placements) { where("placements && ?", placements.to_json) }
  scope :movies, -> { where(featurable_type: 'Movie') }
  scope :tv_episodes, -> { where(featurable_type: 'TvEpisode') }
  scope :tv_shows, -> { where(featurable_type: 'TvShow') }
  
  # Get current featured items for a profile and placement
  def self.current_for(profile, placement: nil)
    items = for_profile(profile).current
    items = items.for_placement(placement) if placement
    items
  end
  
  # Check if this featured item is still valid/current
  def current?
    expires_at.nil? || expires_at > Time.current
  end
  
  # Mark this featured item as expired
  def expire!
    update(expires_at: Time.current)
  end
  
  # Check if this item has a specific placement
  def has_placement?(placement)
    placements.include?(placement)
  end
  
  # Add a placement
  def add_placement(placement)
    return if placements.include?(placement)
    self.placements = placements + [placement]
    save
  end
  
  # Remove a placement
  def remove_placement(placement)
    self.placements = placements - [placement]
    save
  end
end


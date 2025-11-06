class MediaFolder < ApplicationRecord
  # Validations
  validates :name, presence: true, uniqueness: true
  validates :path, presence: true, uniqueness: true
  validate :path_must_exist
  validate :must_have_media_subdirectories
  
  # Scopes
  scope :enabled, -> { where(enabled: true) }
  
  # Expected subdirectories in each folder
  MEDIA_TYPES = %w[TV Movies Music].freeze
  
  # Check if the folder path exists
  def exists?
    File.directory?(path)
  end
  
  # Get the full path to a media type subdirectory
  def media_path(type)
    raise ArgumentError, "Invalid media type: #{type}" unless MEDIA_TYPES.include?(type)
    File.join(path, type)
  end
  
  # Check if a media type subdirectory exists
  def has_media_type?(type)
    File.directory?(media_path(type))
  end
  
  # Get all available media types in this folder
  def available_media_types
    MEDIA_TYPES.select { |type| has_media_type?(type) }
  end
  
  # Get paths for all available media types
  def media_paths
    available_media_types.map { |type| media_path(type) }
  end
  
  # Class method to get all media paths across all enabled folders
  def self.all_media_paths(type = nil)
    paths = []
    enabled.find_each do |media_folder|
      if type
        paths << media_folder.media_path(type) if media_folder.has_media_type?(type)
      else
        paths.concat(media_folder.media_paths)
      end
    end
    paths
  end
  
  # Class method to get all TV paths
  def self.tv_paths
    all_media_paths("TV")
  end
  
  # Class method to get all Movies paths
  def self.movie_paths
    all_media_paths("Movies")
  end
  
  # Class method to get all Music paths
  def self.music_paths
    all_media_paths("Music")
  end
  
  private
  
  def path_must_exist
    unless exists?
      errors.add(:path, "does not exist or is not accessible")
    end
  end
  
  def must_have_media_subdirectories
    if exists? && available_media_types.empty?
      errors.add(:path, "must contain at least one of: #{MEDIA_TYPES.join(', ')}")
    end
  end
end


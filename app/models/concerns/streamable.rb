# frozen_string_literal: true

# Streamable concern for models that support HLS video streaming
# Include this in Movie, TvEpisode, Song, etc.
module Streamable
  extend ActiveSupport::Concern
  
  included do
    # Validations
    validates :status, inclusion: { in: %w[pending processing ready failed] }, allow_nil: true
    
    # Scopes
    scope :ready, -> { where(status: "ready") }
    scope :needs_processing, -> { where(status: [nil, "failed"]) }
    scope :processing, -> { where(status: %w[pending processing]) }
  end
  
  # Status check methods
  def ready?
    status == "ready" && hls_path.present?
  end
  
  def needs_processing?
    status.nil? || status == "failed"
  end
  
  def processing?
    status == "processing" || status == "pending"
  end
  
  # Get the source video file path for processing
  def source_video_path
    file_path
  end
  
  # Get parsed qualities array
  def qualities
    return [] unless hls_qualities.present?
    
    if hls_qualities.is_a?(String)
      hls_qualities.split(',').map(&:strip)
    else
      hls_qualities
    end
  end
  
  # Stream URL helper (to be used in views)
  def stream_url_path
    # This will be overridden by routes, but provides the pattern
    # e.g., /api/movies/1/stream or /api/tv_episodes/1/stream
    raise NotImplementedError, "stream_url_path should be defined by routes"
  end
end


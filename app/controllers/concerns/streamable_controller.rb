# frozen_string_literal: true

# StreamableController concern for controllers that serve HLS streaming
# Include this in MoviesController, TvEpisodesController, etc.
module StreamableController
  extend ActiveSupport::Concern

  included do
    before_action :set_streamable_record, only: [:stream, :segment]
  end

  # GET /api/movies/:id/stream
  # GET /api/tv_episodes/:id/stream
  # Serves the master HLS playlist
  def stream
    # Try to find the master playlist
    playlist_path = find_hls_file("index.m3u8")
    
    if playlist_path && File.exist?(playlist_path)
      # Serve the playlist as-is (it's already generated with correct relative paths)
      send_file playlist_path,
        type: "application/vnd.apple.mpegurl",
        disposition: "inline",
        filename: "index.m3u8"
    else
      render json: { error: "HLS files not found" }, status: :not_found
    end
  end
  
  # GET /api/movies/:id/stream/*segment_path
  # GET /api/tv_episodes/:id/stream/*segment_path
  # Serves individual segments or variant playlists
  def segment
    # Get the segment path from params (e.g., "720p/segment_001.m4s" or "1080p/index.m3u8")
    segment_path = params[:segment_path]
    
    if segment_path.blank?
      render json: { error: "Segment path not provided" }, status: :bad_request
      return
    end
    
    # Find the actual file
    file_path = find_hls_file(segment_path)
    
    if file_path && File.exist?(file_path)
      content_type = determine_content_type(segment_path)
      
      send_file file_path,
        type: content_type,
        disposition: "inline",
        filename: File.basename(segment_path)
    else
      render json: { error: "Segment not found", segment: segment_path }, status: :not_found
    end
  end

  private

  def set_streamable_record
    # Override this in the including controller to set @streamable
    # e.g., @streamable = Movie.find(params[:id])
    raise NotImplementedError, "set_streamable_record must be implemented"
  end

  def find_hls_file(relative_path)
    # Use the record's file_path
    base_dir = Pathname.new(@streamable.file_path)
    
    # Construct the full path
    full_path = base_dir.join(relative_path)
    
    # Security check: ensure the path is within the media's HLS directory
    if full_path.to_s.start_with?(base_dir.to_s)
      full_path.to_s
    else
      nil
    end
  end
  
  def determine_content_type(filename)
    case File.extname(filename).downcase
    when ".m3u8"
      "application/vnd.apple.mpegurl"
    when ".ts"
      "video/mp2t"
    when ".mp4", ".m4s"
      "video/mp4"
    when ".vtt"
      "text/vtt"
    else
      "application/octet-stream"
    end
  end
end


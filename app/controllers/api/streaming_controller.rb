class Api::StreamingController < ApplicationController
  before_action :set_record, only: [:stream, :segment]
  
  # GET /media/:id/stream OR /movies/:id/stream OR /tv_episodes/:id/stream
  # Serves the master playlist
  def stream
    # Try to find the master playlist
    playlist_path = find_hls_file("index.m3u8")
    
    if playlist_path && File.exist?(playlist_path)
      # Read and rewrite the playlist to use correct URL paths
      playlist_content = File.read(playlist_path)
      
      # Rewrite relative paths to include 'stream/' prefix so they resolve correctly
      # This fixes relative URL resolution: 720p/index.m3u8 -> stream/720p/index.m3u8
      rewritten_content = playlist_content.gsub(/^([^#\s].+\.m3u8)$/) do |match|
        "stream/#{match}"
      end
      
      render plain: rewritten_content,
        content_type: "application/vnd.apple.mpegurl"
    else
      render json: { error: "HLS files not found" }, status: :not_found
    end
  end
  
  # GET /media/:id/stream/*segment_path
  # Serves individual segments or variant playlists
  def segment
    # Get the segment path from params (e.g., "4k/segment_001.ts" or "1080p_high/index.m3u8")
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
  
  def set_record
    # Determine the model type based on the route parameters
    @record_type, @record = find_streamable_record
    
    unless @record
      render json: { error: "#{@record_type.to_s.humanize} not found" }, status: :not_found
      return
    end
    
    # Check if HLS files are ready
    unless @record.file_path.present?
      render json: { 
        error: "Video not yet processed", 
        status: @record.status || "pending" 
      }, status: :not_found
      return
    end
    
  rescue ActiveRecord::RecordNotFound
    render json: { error: "#{@record_type.to_s.humanize} not found" }, status: :not_found
  end
  
  # Find the streamable record based on route parameters
  def find_streamable_record
    # Check for movie_id parameter (from nested route)
    if params[:movie_id].present?
      [:movie, Movie.find(params[:movie_id])]
    # Check for tv_episode_id parameter (from nested route)
    elsif params[:tv_episode_id].present?
      [:tv_episode, TvEpisode.find(params[:tv_episode_id])]
    # Check for song_id parameter (from nested route)
    elsif params[:song_id].present?
      [:song, Song.find(params[:song_id])]
    # Fallback to checking path
    elsif request.path.include?('/movies/')
      [:movie, Movie.find(params[:id])]
    elsif request.path.include?('/tv_episodes/')
      [:tv_episode, TvEpisode.find(params[:id])]
    elsif request.path.include?('/songs/')
      [:song, Song.find(params[:id])]
    else
      raise ActiveRecord::RecordNotFound, "Unknown streamable resource"
    end
  end
  
  def find_hls_file(relative_path)
    # Use the record's file_path
    base_dir = Pathname.new(@record.file_path)
    
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
    when ".mp4"
      "video/mp4"
    when ".vtt"
      "text/vtt"
    else
      "application/octet-stream"
    end
  end
end

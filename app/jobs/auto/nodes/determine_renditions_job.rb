module Auto
  module Nodes
    # DetermineRenditionsJob - Determine which renditions to create based on source
    #
    # Takes ffprobe output and returns lists of audio, video, and subtitle renditions needed
    #
    # Args:
    #   Required:
    #   - ffprobe_output: The output from an ffprobe node
    #
    # Returns:
    #   data:
    #     audio: Array of audio rendition configs
    #     video: Array of video rendition configs
    #     needs_subtitles: Boolean
    #
    # Example:
    #   type: determine_renditions
    #   args:
    #     ffprobe_output: "${detect_source_info.output}"
    class DetermineRenditionsJob < NodeJob
      def execute(node)
        args = node.args
        
        ffprobe_output = args[:ffprobe_output]
        raise ArgumentError, "ffprobe_output is required" unless ffprobe_output.present?
        
        data = ffprobe_output
        
        # Get video properties
        video_stream = data['streams'].find { |s| s['codec_type'] == 'video' }
        height = video_stream['height'].to_i
        
        # Parse frame rate (e.g., "24000/1001" = 23.976)
        fps_str = video_stream['r_frame_rate'] || video_stream['avg_frame_rate']
        source_fps = eval(fps_str).to_f rescue 30.0
        
        # Detect if source is HDR/Dolby Vision
        color_transfer = video_stream['color_transfer']
        color_space = video_stream['color_space']
        has_dv = video_stream['side_data_list']&.any? { |sd| sd['side_data_type']&.include?('DOVI') }
        
        is_hdr = color_transfer == 'smpte2084' ||  # HDR10/PQ
                 color_transfer == 'arib-std-b67' || # HLG
                 color_space == 'bt2020nc' ||        # BT.2020
                 has_dv                              # Dolby Vision
        
        # Determine target FPS
        # Normalize frame rates for optimal display on 60/120Hz displays:
        #   - < 50 fps (film, PAL TV, NTSC) → 29.97 fps
        #   - >= 50 fps (sports, HFR) → 59.94 fps
        # This ensures smooth playback on all modern displays
        target_fps = if source_fps >= 50
          "60000/1001"  # Normalize all HFR to 59.94 fps (60/120Hz compatible)
        else
          "30000/1001"  # Normalize standard content to 29.97 fps
        end
        
        audio_stream = data['streams'].find { |s| s['codec_type'] == 'audio' }
        channels = audio_stream ? audio_stream['channels'].to_i : 2
        
        # Determine if we need to download subtitles (vs extract from source)
        subtitle_streams = data['streams'].select { |s| s['codec_type'] == 'subtitle' }
        
        needs_subtitle_download = if subtitle_streams.empty?
          # No subtitles in source - download from OpenSubtitles
          true
        elsif subtitle_streams.first['codec_name'] == 'hdmv_pgs_subtitle'
          # PGS (image-based) subtitles - download text version instead
          true
        else
          # Has text-based subtitles - extract directly from source
          false
        end
        
        # Determine audio renditions needed
        audio_renditions = [
          { variant_name: 'audio_stereo', bitrate: '192k', channels: 2 }
        ]
        
        # Add surround if source has 5.1+
        if channels >= 6
          audio_renditions << { variant_name: 'audio_surround', bitrate: '320k', channels: 6 }
        end
        
        # Determine video renditions needed based on source height
        video_renditions = case height
        when 2160..Float::INFINITY  # 4K source
          [
            { variant_name: 'video_4k', width: 3840, height: 2160, bitrate: '25M', fps: target_fps, is_hdr: is_hdr },
            { variant_name: 'video_1080p', width: 1920, height: 1080, bitrate: '12M', fps: target_fps, is_hdr: is_hdr },
            { variant_name: 'video_720p', width: 1280, height: 720, bitrate: '5M', fps: target_fps, is_hdr: is_hdr }
          ]
        when 1080..2159  # 1080p source
          [
            { variant_name: 'video_1080p', width: 1920, height: 1080, bitrate: '12M', fps: target_fps, is_hdr: is_hdr },
            { variant_name: 'video_720p', width: 1280, height: 720, bitrate: '5M', fps: target_fps, is_hdr: is_hdr }
          ]
        when 720..1079  # 720p source
          [
            { variant_name: 'video_720p', width: 1280, height: 720, bitrate: '5M', fps: target_fps, is_hdr: is_hdr }
          ]
        else  # < 720p source
          [
            { variant_name: 'video_source', width: nil, height: nil, bitrate: '3M', fps: target_fps, is_hdr: is_hdr }
          ]
        end
        
        log_info(node, "Source: #{height}p @ #{source_fps.round(2)}fps, #{is_hdr ? 'HDR' : 'SDR'}, #{channels}ch, subs: #{needs_subtitle_download ? 'download' : 'extract'} → Target: #{target_fps} → #{audio_renditions.size} audio, #{video_renditions.size} video")
        
        {
          data: {
            audio: audio_renditions,
            video: video_renditions,
            needs_subtitle_download: needs_subtitle_download
          },
          selection: :default
        }
      end
    end
  end
end


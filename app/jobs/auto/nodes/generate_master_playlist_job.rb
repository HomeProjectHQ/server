module Auto
    module Nodes
      # GenerateMasterPlaylistJob - Create HLS master playlist from available renditions
      #
      # Scans the output directory for available audio, video, and subtitle renditions
      # and generates an HLS master playlist that references them.
      #
      # Args:
      #   Required:
      #   - base_dir: Base directory containing rendition subdirectories
      #
      #   Optional:
      #   - has_subtitles: Override subtitle detection (default: auto-detect from subtitles_en/)
      #
      # Example:
      #   type: generate_master_playlist
      #   args:
      #     base_dir: "${Setting.root_path}/TV Shows/${subject.tv_season.tv_show.title}/s${subject.tv_season.season_number}e${subject.episode_number}"
      class GenerateMasterPlaylistJob < NodeJob
      def execute(node)
        args = node.args
        
        base_dir = args[:base_dir]
        is_hdr = args[:is_hdr] || false
        raise ArgumentError, "base_dir is required" unless base_dir.present?
          
          unless Dir.exist?(base_dir)
            raise "Base directory not found: #{base_dir}"
          end
          
          log_info(node, "Generating master playlist in #{base_dir}")
          
        # Build playlist content
        playlist = build_playlist(base_dir, args.merge(is_hdr: is_hdr))
          
          # Write playlist file
          playlist_path = File.join(base_dir, "index.m3u8")
          File.write(playlist_path, playlist.join("\n"))
          
          log_info(node, "Master playlist created: #{playlist_path}")
          
          {
            data: {
              base_dir: base_dir,
              playlist_path: playlist_path,
              line_count: playlist.size
            },
            selection: :default
          }
        end
        
        private
        
        def build_playlist(base_dir, args)
          playlist = [
            "#EXTM3U",
            "#EXT-X-VERSION:6",
            ""
          ]
          
          # Check for subtitle renditions
          has_subtitles = args[:has_subtitles].nil? ? 
            File.exist?(File.join(base_dir, "subtitles_en/index.m3u8")) : 
            args[:has_subtitles]
          
          if has_subtitles
            playlist << "# Subtitle renditions"
            playlist << '#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",NAME="English",DEFAULT=NO,AUTOSELECT=NO,LANGUAGE="en",URI="subtitles_en/index.m3u8"'
            playlist << ""
          end
          
          # Add audio renditions
          add_audio_renditions(playlist, base_dir)
          
          # Add video variants
          is_hdr = args[:is_hdr] || false
          add_video_variants(playlist, base_dir, has_subtitles, is_hdr)
          
          playlist
        end
        
        def add_audio_renditions(playlist, base_dir)
          playlist << "# Audio renditions"
          
          # Check for stereo audio
          if File.exist?(File.join(base_dir, "audio_stereo/index.m3u8"))
            playlist << '#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio",NAME="Stereo",DEFAULT=YES,AUTOSELECT=YES,LANGUAGE="en",URI="audio_stereo/index.m3u8"'
          end
          
          # Check for surround audio
          if File.exist?(File.join(base_dir, "audio_surround/index.m3u8"))
            playlist << '#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio",NAME="Surround 5.1",DEFAULT=NO,AUTOSELECT=YES,LANGUAGE="en",CHANNELS="6",URI="audio_surround/index.m3u8"'
          end
          
          playlist << ""
        end
        
        def add_video_variants(playlist, base_dir, has_subtitles, is_hdr)
          # Define video variants in priority order
          # Check for both HDR and SDR versions (new naming: video_4k_hdr, video_4k_sdr)
          video_variants = [
            { dir: "video_4k_hdr", bandwidth: 25000000, resolution: "3840x2160", name: "4K HDR", is_hdr_variant: true },
            { dir: "video_4k_sdr", bandwidth: 25000000, resolution: "3840x2160", name: "4K SDR", is_hdr_variant: false },
            { dir: "video_4k", bandwidth: 25000000, resolution: "3840x2160", name: "4K", is_hdr_variant: is_hdr },  # Legacy
            { dir: "video_1080p_hdr", bandwidth: 12192000, resolution: "1920x1080", name: "1080p HDR", is_hdr_variant: true },
            { dir: "video_1080p_sdr", bandwidth: 12192000, resolution: "1920x1080", name: "1080p SDR", is_hdr_variant: false },
            { dir: "video_1080p", bandwidth: 12192000, resolution: "1920x1080", name: "1080p", is_hdr_variant: is_hdr },  # Legacy
            { dir: "video_720p", bandwidth: 5192000, resolution: "1280x720", name: "720p", is_hdr_variant: false },
            { dir: "video_source", bandwidth: 3000000, resolution: nil, name: "Source", is_hdr_variant: false }
          ]
          
          subs_attr = has_subtitles ? ',SUBTITLES="subs"' : ''
          
        video_variants.each do |variant|
          variant_path = File.join(base_dir, variant[:dir], "index.m3u8")
          
          next unless File.exist?(variant_path)
          
          # Build stream info attributes
          res_attr = variant[:resolution] ? ",RESOLUTION=#{variant[:resolution]}" : ""
          
          # Determine codec string based on whether THIS VARIANT is HDR (not source)
          # CODECS: hvc1 = HEVC, mp4a.40.2 = AAC-LC
          # Format: hvc1.profile.tier.level.constraints
          # For 10-bit HDR Main 10: hvc1.2.4.L123.B0 (profile=2, main tier, level 4.1, Safari compatible)
          # For 8-bit SDR Main: hvc1.1.6.L120.B0 (profile=1, high tier, level 4.0, 8-bit constraints)
          is_hdr_variant = variant[:is_hdr_variant]
          codecs = is_hdr_variant ? "hvc1.2.4.L123.B0,mp4a.40.2" : "hvc1.1.6.L120.B0,mp4a.40.2"
          
          # Apple HLS requirements (Rules 9.14, 9.15, 9.16)
          # AVERAGE-BANDWIDTH is required (for VOD, same as BANDWIDTH)
          # FRAME-RATE is required for video content (29.970 fps for our transcodes)
          # VIDEO-RANGE must be specified for ALL variants (SDR or PQ for HDR)
          avg_bandwidth = variant[:bandwidth]
          frame_rate = "29.970"
          video_range_attr = is_hdr_variant ? ",VIDEO-RANGE=PQ" : ",VIDEO-RANGE=SDR"
          
          playlist << "# #{variant[:name]} variant"
          playlist << "#EXT-X-STREAM-INF:BANDWIDTH=#{variant[:bandwidth]},AVERAGE-BANDWIDTH=#{avg_bandwidth}#{res_attr},FRAME-RATE=#{frame_rate},CODECS=\"#{codecs}\"#{video_range_attr},AUDIO=\"audio\"#{subs_attr}"
          playlist << "#{variant[:dir]}/index.m3u8"
          playlist << ""
        end
        end
      end
    end
  end
  
  
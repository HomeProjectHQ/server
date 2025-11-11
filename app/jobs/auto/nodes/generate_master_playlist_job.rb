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
          raise ArgumentError, "base_dir is required" unless base_dir.present?
          
          unless Dir.exist?(base_dir)
            raise "Base directory not found: #{base_dir}"
          end
          
          log_info(node, "Generating master playlist in #{base_dir}")
          
          # Build playlist content
          playlist = build_playlist(base_dir, args)
          
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
          add_video_variants(playlist, base_dir, has_subtitles)
          
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
        
        def add_video_variants(playlist, base_dir, has_subtitles)
          # Define video variants in priority order
          video_variants = [
            { dir: "video_4k", bandwidth: 25000000, resolution: "3840x2160", name: "4K" },
            { dir: "video_1080p", bandwidth: 12192000, resolution: "1920x1080", name: "1080p" },
            { dir: "video_720p", bandwidth: 5192000, resolution: "1280x720", name: "720p" },
            { dir: "video_source", bandwidth: 3000000, resolution: nil, name: "Source" }
          ]
          
          subs_attr = has_subtitles ? ',SUBTITLES="subs"' : ''
          
          video_variants.each do |variant|
            variant_path = File.join(base_dir, variant[:dir], "index.m3u8")
            
            next unless File.exist?(variant_path)
            
            # Build stream info attributes
            res_attr = variant[:resolution] ? ",RESOLUTION=#{variant[:resolution]}" : ""
            
            playlist << "# #{variant[:name]} variant"
            playlist << "#EXT-X-STREAM-INF:BANDWIDTH=#{variant[:bandwidth]}#{res_attr},AUDIO=\"audio\"#{subs_attr}"
            playlist << "#{variant[:dir]}/index.m3u8"
            playlist << ""
          end
        end
      end
    end
  end
  
  
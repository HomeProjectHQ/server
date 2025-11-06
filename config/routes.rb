Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Auto workflow engine
  mount Auto::Engine, at: "/auto"

  # API routes
  namespace :api do
    # Profile management
    resources :profiles, only: [:index] do
      member do
        # Profile-specific media endpoints
        get 'movies', to: 'profile_movies#index'
        get 'movies/:movie_id', to: 'profile_movies#show', as: 'movie'
        
        get 'tv_shows', to: 'profile_tv_shows#index'
        get 'tv_shows/:tv_show_id', to: 'profile_tv_shows#show', as: 'tv_show'
        get 'tv_shows/:tv_show_id/seasons', to: 'profile_tv_shows#seasons'
        get 'tv_shows/:tv_show_id/seasons/:season_number/episodes', to: 'profile_tv_shows#episodes'
        
        get 'music/artists', to: 'profile_music#artists'
        get 'music/artists/:artist_id', to: 'profile_music#artist', as: 'music_artist'
        get 'music/artists/:artist_id/albums', to: 'profile_music#albums'
        get 'music/albums/:album_id/songs', to: 'profile_music#album_songs', as: 'music_album_songs'
        get 'music/songs', to: 'profile_music#songs'
        
        # Watch progress tracking
        get 'watch_progresses', to: 'watch_progresses#index', as: 'watch_progresses'
        get 'watch_progresses/:watchable_type/:watchable_id', to: 'watch_progresses#show', as: 'watch_progress'
        put 'watch_progresses/:watchable_type/:watchable_id', to: 'watch_progresses#update'
        patch 'watch_progresses/:watchable_type/:watchable_id', to: 'watch_progresses#update'
        
        # TV show next episode helper
        get 'tv_shows/:tv_show_id/next_episode', to: 'watch_progresses#next_episode', as: 'next_episode'
        
        # Recommendations (up next)
        get 'recommendations/up_next', to: 'recommendations#up_next', as: 'recommendations_up_next'
        
        # Featured items (personalized recommendations with placements)
        get 'featured', to: 'featured_items#index', as: 'featured_items'
        post 'featured/generate', to: 'featured_items#generate', as: 'generate_featured_items'
        delete 'featured', to: 'featured_items#destroy'
        get 'featured/history', to: 'featured_items#history', as: 'featured_items_history'
      end
    end
    
    # Library endpoints
    resources :movies, only: [:index, :show] do
      member do
        get 'stream', to: 'streaming#stream', as: 'stream'
        get 'stream/*segment_path', to: 'streaming#segment', as: 'segment', format: false
      end
    end
    
    resources :tv_shows, only: [:index, :show] do
      member do
        get 'seasons'
        get 'seasons/:season_number/episodes', to: 'tv_shows#episodes', as: 'season_episodes'
      end
    end
    
    # TV Episode endpoints
    resources :tv_episodes, only: [:show] do
      member do
        get 'stream', to: 'streaming#stream', as: 'stream'
        get 'stream/*segment_path', to: 'streaming#segment', as: 'segment', format: false
      end
    end
    
    resources :artists, only: [:index, :show] do
      member do
        get 'albums'
        get 'albums/:album_id/songs', to: 'artists#album_songs', as: 'album_songs'
      end
    end
    
    # Song streaming endpoints (for future audio streaming)
    resources :songs, only: [] do
      member do
        get 'stream', to: 'streaming#stream', as: 'stream'
        get 'stream/*segment_path', to: 'streaming#segment', as: 'segment', format: false
      end
    end
    
    # Admin routes
    namespace :admin do
      # Media Folder management
      resources :media_folders do
        collection do
          get 'media_paths'
        end
      end
      
      # Library management
      post 'library/scan', to: 'library#scan'
      get 'library/scan_status', to: 'library#scan_status'
      
      # Media catalog management (no profile filtering)
      resources :movies, only: [:index, :show]
      resources :tv_shows, only: [:index, :show]
      resources :artists, only: [:index, :show] do
        member do
          get 'albums'
        end
      end
      
      resources :profiles do
        # Profile's movie access management
        resources :movies, only: [:index, :create, :destroy], controller: 'profile_movies' do
          collection do
            delete ':movie_id', action: :destroy
          end
        end
        
        # Profile's TV show access management
        resources :tv_shows, only: [:index, :create, :destroy], controller: 'profile_tv_shows' do
          collection do
            delete ':tv_show_id', action: :destroy
          end
        end
        
        # Profile's song access management
        resources :songs, only: [:index, :create, :destroy], controller: 'profile_songs' do
          collection do
            delete ':song_id', action: :destroy
          end
        end
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end

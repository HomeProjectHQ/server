# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_11_05_173735) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "ltree"
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "albums", force: :cascade do |t|
    t.string "title"
    t.bigint "artist_id", null: false
    t.integer "year"
    t.string "cover_url"
    t.string "mbid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_id"], name: "index_albums_on_artist_id"
  end

  create_table "artists", force: :cascade do |t|
    t.string "name"
    t.string "mbid"
    t.text "bio"
    t.string "image_url"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "auto_node_edges", force: :cascade do |t|
    t.bigint "from_node_id", null: false
    t.bigint "to_node_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_node_id", "to_node_id"], name: "index_auto_node_edges_on_from_node_id_and_to_node_id", unique: true
    t.index ["to_node_id"], name: "index_auto_node_edges_on_to_node_id"
  end

  create_table "auto_nodes", force: :cascade do |t|
    t.bigint "workflow_id", null: false
    t.string "node_id", null: false
    t.integer "node_index", null: false
    t.integer "status", default: 0, null: false
    t.string "selection", default: "0"
    t.bigint "job_id"
    t.string "job_class"
    t.text "error_details"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "data"
    t.boolean "end", default: false, null: false
    t.integer "depth", default: 0
    t.index ["end"], name: "index_auto_nodes_on_end"
    t.index ["job_id"], name: "index_auto_nodes_on_job_id"
    t.index ["node_id"], name: "index_auto_nodes_on_node_id"
    t.index ["status"], name: "index_auto_nodes_on_status"
    t.index ["workflow_id", "node_index"], name: "index_auto_nodes_on_workflow_id_and_node_index", unique: true
    t.index ["workflow_id"], name: "index_auto_nodes_on_workflow_id"
  end

  create_table "auto_workflows", force: :cascade do |t|
    t.string "workflow_id", null: false
    t.integer "status", default: 0, null: false
    t.string "subject_type"
    t.bigint "subject_id"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_workflow_id"
    t.jsonb "args", default: {}, null: false
    t.index ["args"], name: "index_auto_workflows_on_args", using: :gin
    t.index ["parent_workflow_id"], name: "index_auto_workflows_on_parent_workflow_id"
    t.index ["status"], name: "index_auto_workflows_on_status"
    t.index ["subject_type", "subject_id"], name: "index_auto_executions_on_subject"
    t.index ["subject_type", "subject_id"], name: "index_auto_workflows_on_subject_type_and_subject_id"
    t.index ["workflow_id"], name: "index_auto_workflows_on_workflow_id"
  end

  create_table "genres", force: :cascade do |t|
    t.integer "tmdb_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tmdb_id"], name: "index_genres_on_tmdb_id", unique: true
  end

  create_table "media", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "status"
    t.string "hls_path"
    t.integer "duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "media_folders", force: :cascade do |t|
    t.string "name", null: false
    t.string "path", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "enabled", default: true, null: false
    t.index ["enabled"], name: "index_media_folders_on_enabled"
    t.index ["name"], name: "index_media_folders_on_name", unique: true
    t.index ["path"], name: "index_media_folders_on_path", unique: true
  end

  create_table "movie_genres", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.bigint "genre_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["genre_id"], name: "index_movie_genres_on_genre_id"
    t.index ["movie_id", "genre_id"], name: "index_movie_genres_on_movie_id_and_genre_id", unique: true
    t.index ["movie_id"], name: "index_movie_genres_on_movie_id"
  end

  create_table "movies", force: :cascade do |t|
    t.string "title"
    t.integer "tmdb_id"
    t.integer "year"
    t.text "overview"
    t.string "poster_path"
    t.string "backdrop_path"
    t.integer "runtime"
    t.decimal "rating"
    t.string "file_path"
    t.bigint "file_size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hls_path"
    t.string "status"
    t.integer "duration"
    t.string "imdb_id"
    t.text "tagline"
    t.decimal "vote_average"
    t.integer "vote_count"
    t.date "release_date"
    t.decimal "popularity"
    t.string "original_language"
    t.string "original_title"
    t.bigint "budget"
    t.bigint "revenue"
    t.string "homepage"
    t.index ["tmdb_id"], name: "index_movies_on_tmdb_id", unique: true
  end

  create_table "profile_movies", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.bigint "movie_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_profile_movies_on_movie_id"
    t.index ["profile_id"], name: "index_profile_movies_on_profile_id"
  end

  create_table "profile_songs", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.bigint "song_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_profile_songs_on_profile_id"
    t.index ["song_id"], name: "index_profile_songs_on_song_id"
  end

  create_table "profile_tv_shows", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.bigint "tv_show_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_profile_tv_shows_on_profile_id"
    t.index ["tv_show_id"], name: "index_profile_tv_shows_on_tv_show_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "color"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.string "key", null: false
    t.string "schedule", null: false
    t.string "command", limit: 2048
    t.string "class_name"
    t.text "arguments"
    t.string "queue_name"
    t.integer "priority", default: 0
    t.boolean "static", default: true, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "songs", force: :cascade do |t|
    t.string "title"
    t.bigint "album_id", null: false
    t.integer "track_number"
    t.integer "duration"
    t.string "file_path"
    t.bigint "file_size"
    t.string "mbid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.string "hls_path"
    t.integer "hls_duration"
    t.text "hls_qualities"
    t.index ["album_id"], name: "index_songs_on_album_id"
  end

  create_table "tv_episodes", force: :cascade do |t|
    t.bigint "tv_season_id", null: false
    t.integer "episode_number"
    t.string "title"
    t.text "overview"
    t.date "air_date"
    t.integer "runtime"
    t.string "still_path"
    t.string "file_path"
    t.bigint "file_size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.string "hls_path"
    t.integer "hls_duration"
    t.text "hls_qualities"
    t.index ["tv_season_id"], name: "index_tv_episodes_on_tv_season_id"
  end

  create_table "tv_seasons", force: :cascade do |t|
    t.bigint "tv_show_id", null: false
    t.integer "season_number"
    t.string "name"
    t.text "overview"
    t.string "poster_path"
    t.date "air_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tv_show_id"], name: "index_tv_seasons_on_tv_show_id"
  end

  create_table "tv_show_genres", force: :cascade do |t|
    t.bigint "tv_show_id", null: false
    t.bigint "genre_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["genre_id"], name: "index_tv_show_genres_on_genre_id"
    t.index ["tv_show_id", "genre_id"], name: "index_tv_show_genres_on_tv_show_id_and_genre_id", unique: true
    t.index ["tv_show_id"], name: "index_tv_show_genres_on_tv_show_id"
  end

  create_table "tv_shows", force: :cascade do |t|
    t.string "title"
    t.integer "tvdb_id"
    t.integer "tmdb_id"
    t.integer "year"
    t.text "overview"
    t.string "poster_path"
    t.string "backdrop_path"
    t.string "status"
    t.string "network"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "tagline"
    t.decimal "vote_average"
    t.integer "vote_count"
    t.date "first_air_date"
    t.date "last_air_date"
    t.decimal "popularity"
    t.string "original_language"
    t.string "original_name"
    t.string "homepage"
    t.integer "number_of_episodes"
    t.integer "number_of_seasons"
    t.boolean "in_production"
    t.string "type"
    t.index ["tmdb_id"], name: "index_tv_shows_on_tmdb_id", unique: true
  end

  create_table "watch_progresses", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.string "watchable_type", null: false
    t.bigint "watchable_id", null: false
    t.integer "position_seconds", default: 0, null: false
    t.integer "duration_seconds"
    t.boolean "completed", default: false, null: false
    t.datetime "last_watched_at"
    t.integer "watch_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id", "last_watched_at"], name: "index_watch_progresses_on_profile_id_and_last_watched_at"
    t.index ["profile_id", "watchable_type", "watchable_id"], name: "index_watch_progresses_uniqueness", unique: true
    t.index ["profile_id"], name: "index_watch_progresses_on_profile_id"
    t.index ["watchable_type", "watchable_id"], name: "index_watch_progresses_on_watchable"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "albums", "artists"
  add_foreign_key "auto_node_edges", "auto_nodes", column: "from_node_id"
  add_foreign_key "auto_node_edges", "auto_nodes", column: "to_node_id"
  add_foreign_key "auto_nodes", "auto_workflows", column: "workflow_id"
  add_foreign_key "movie_genres", "genres"
  add_foreign_key "movie_genres", "movies"
  add_foreign_key "profile_movies", "movies"
  add_foreign_key "profile_movies", "profiles"
  add_foreign_key "profile_songs", "profiles"
  add_foreign_key "profile_songs", "songs"
  add_foreign_key "profile_tv_shows", "profiles"
  add_foreign_key "profile_tv_shows", "tv_shows"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "songs", "albums"
  add_foreign_key "tv_episodes", "tv_seasons"
  add_foreign_key "tv_seasons", "tv_shows"
  add_foreign_key "tv_show_genres", "genres"
  add_foreign_key "tv_show_genres", "tv_shows"
  add_foreign_key "watch_progresses", "profiles"
end

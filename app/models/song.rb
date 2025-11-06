class Song < ApplicationRecord
  include Streamable
  
  belongs_to :album
  has_one :artist, through: :album
  
  has_many :profile_songs, dependent: :destroy
  has_many :profiles, through: :profile_songs
  
  # Watch progress tracking
  has_many :watch_progresses, as: :watchable, dependent: :destroy
  
  validates :title, presence: true
  validates :file_path, presence: true, uniqueness: true
end

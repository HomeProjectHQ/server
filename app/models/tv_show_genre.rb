class TvShowGenre < ApplicationRecord
  belongs_to :tv_show
  belongs_to :genre
  
  validates :tv_show_id, uniqueness: { scope: :genre_id }
end

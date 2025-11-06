class AddColorToProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :profiles, :color, :string
  end
end

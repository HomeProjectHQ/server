class AddPromptToProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :profiles, :prompt, :text
  end
end


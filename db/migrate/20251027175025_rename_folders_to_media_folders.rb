class RenameFoldersToMediaFolders < ActiveRecord::Migration[8.0]
  def change
    rename_table :folders, :media_folders
  end
end

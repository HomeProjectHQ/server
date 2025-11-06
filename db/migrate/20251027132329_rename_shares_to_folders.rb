class RenameSharesToFolders < ActiveRecord::Migration[8.0]
  def change
    rename_table :shares, :folders
    
    # Remove mounting-related columns
    remove_column :folders, :host, :string
    remove_column :folders, :share_path, :string
    remove_column :folders, :username, :string
    remove_column :folders, :password, :string
    remove_column :folders, :mount_status, :string
    remove_column :folders, :last_mounted_at, :datetime
    
    # Rename mount_point to path
    rename_column :folders, :mount_point, :path
    
    # Remove old indexes
    remove_index :folders, :mount_status if index_exists?(:folders, :mount_status)
    
    # Add new columns
    add_column :folders, :enabled, :boolean, default: true, null: false
    
    # Add enabled index (path index already exists from column rename)
    add_index :folders, :enabled
  end
end

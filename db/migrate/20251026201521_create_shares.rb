class CreateShares < ActiveRecord::Migration[8.0]
  def change
    create_table :shares do |t|
      t.string :name, null: false
      t.string :host, null: false
      t.string :share_path, null: false
      t.string :username, null: false
      t.string :password, null: false  # Will be encrypted via Active Record Encryption
      t.string :mount_point, null: false
      t.string :mount_status, default: "unmounted"
      t.datetime :last_mounted_at

      t.timestamps
    end
    
    add_index :shares, :name, unique: true
    add_index :shares, :mount_point, unique: true
    add_index :shares, :mount_status
  end
end

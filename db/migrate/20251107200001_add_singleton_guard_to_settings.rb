class AddSingletonGuardToSettings < ActiveRecord::Migration[8.0]
  def up
    # Remove the old check constraint
    remove_check_constraint :settings, name: "settings_singleton_check"
    
    # Add singleton_guard column
    add_column :settings, :singleton_guard, :integer, null: false, default: 0
    
    # Update existing record to have singleton_guard = 0
    execute "UPDATE settings SET singleton_guard = 0"
    
    # Add unique index on singleton_guard
    add_index :settings, :singleton_guard, unique: true
  end
  
  def down
    remove_index :settings, :singleton_guard
    remove_column :settings, :singleton_guard
    add_check_constraint :settings, "id = 1", name: "settings_singleton_check"
  end
end


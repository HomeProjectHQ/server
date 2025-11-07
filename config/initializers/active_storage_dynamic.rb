# Configure ActiveStorage to use dynamic paths from Settings
# This runs after the database is available

Rails.application.configure do
  # This will run after initialization, when the database is available
  config.after_initialize do
    # Only configure if the settings table exists and we're not in a migration
    if ActiveRecord::Base.connection.table_exists?('settings')
      begin
        storage_path = File.join(Setting.root_path, "storage")
        
        # Dynamically define a custom storage service
        Rails.configuration.active_storage.service_configurations ||= {}
        Rails.configuration.active_storage.service_configurations['dynamic'] = {
          'service' => 'Disk',
          'root' => storage_path
        }
        
        # Note: The service is already set in environment configs (local/test/etc)
        # This just makes the dynamic path available if you want to use it
        # To use it, change config.active_storage.service = :dynamic in your environment files
        
      rescue ActiveRecord::StatementInvalid, ActiveRecord::NoDatabaseError
        # Database not ready yet, skip
        Rails.logger.debug "Skipping ActiveStorage dynamic configuration - database not ready"
      end
    end
  end
end


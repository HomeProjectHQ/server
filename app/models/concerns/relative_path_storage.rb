# frozen_string_literal: true

# RelativePathStorage concern for models that store paths relative to Setting.root_path
# This allows the system to be portable - if root_path changes, all relative paths still work
module RelativePathStorage
  extend ActiveSupport::Concern
  
  # Override file_path getter to return absolute path
  def file_path
    relative_path = self[:file_path]
    return nil unless relative_path.present?
    
    # If it's already absolute (migration hasn't run yet), return as-is
    return relative_path if relative_path.start_with?('/')
    
    # Otherwise, join with root path
    File.join(Setting.root_path, relative_path)
  end
  
  # Override file_path setter to store as relative path
  def file_path=(value)
    return self[:file_path] = nil if value.nil?
    
    root = Setting.root_path
    
    # If the path starts with root_path, make it relative
    if value.start_with?(root)
      relative = value.sub(/^#{Regexp.escape(root)}\/?/, '')
      self[:file_path] = relative
    else
      # Store as-is if it doesn't start with root_path
      # This handles cases where paths are already relative or from different locations
      self[:file_path] = value
    end
  end
  
  # Get the raw relative path as stored in the database
  def relative_file_path
    self[:file_path]
  end
  
  # Get the full absolute streaming path
  def absolute_file_path
    file_path
  end
end


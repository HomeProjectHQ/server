class Setting < ApplicationRecord
  # Singleton pattern using singleton_guard column
  # The unique index on singleton_guard (always 0) ensures only one row exists
  
  # Validations
  validates :singleton_guard, inclusion: { in: [0] }
  validates :root_path, presence: true
  validates :max_transcode_quality, inclusion: { in: [720, 1080, 2160] }
  validates :scan_interval_minutes, numericality: { greater_than: 0 }
  
  # Get the singleton instance
  def self.instance
    where(singleton_guard: 0).first_or_create!
  end
  
  # Delegate class methods to the instance for easy access
  # Setting.root_path instead of Setting.instance.root_path
  def self.method_missing(method, *args)
    instance.public_send(method, *args)
  rescue NoMethodError
    super
  end
  
  def self.respond_to_missing?(method, include_private = false)
    instance.respond_to?(method, include_private) || super
  end
end


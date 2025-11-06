# frozen_string_literal: true

# This migration comes from auto (originally 20251103000007)
class ChangeJobIdToBigint < ActiveRecord::Migration[8.0]
  def up
    # Change job_id from string to bigint to match SolidQueue::Job.id type
    # This eliminates type conversion issues in repair logic
    change_column :auto_node_executions, :job_id, :bigint, using: 'job_id::bigint'
  end
  
  def down
    # Revert back to string if needed
    change_column :auto_node_executions, :job_id, :string
  end
end


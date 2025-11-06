# This migration comes from auto (originally 20251031000001)
class AddFinishedStatusToNodeExecutions < ActiveRecord::Migration[8.0]
  def up
    # Add 'finished' status (value 3) between 'running' (2) and 'complete' (4)
    # Old statuses: pending: 0, scheduled: 1, running: 2, completed: 3, failed: 4
    # New statuses: pending: 0, scheduled: 1, running: 2, finished: 3, complete: 4, failed: 5
    
    # First, update existing 'failed' (4) to new value (5)
    execute <<-SQL
      UPDATE auto_node_executions 
      SET status = 5 
      WHERE status = 4;  -- failed: 4 → 5
    SQL
    
    # Then update existing 'completed' (3) to 'complete' (4)
    execute <<-SQL
      UPDATE auto_node_executions 
      SET status = 4 
      WHERE status = 3;  -- completed: 3 → complete: 4
    SQL
    
    # Note: Any nodes currently at complete (4) are already processed by scheduler
    # So they should stay at complete (4), not be moved to finished (3)
  end
  
  def down
    # Reverse the migration: move everything back
    execute <<-SQL
      UPDATE auto_node_executions 
      SET status = 3 
      WHERE status = 4;  -- complete: 4 → completed: 3
    SQL
    
    execute <<-SQL
      UPDATE auto_node_executions 
      SET status = 4 
      WHERE status = 5;  -- failed: 5 → 4
    SQL
  end
end


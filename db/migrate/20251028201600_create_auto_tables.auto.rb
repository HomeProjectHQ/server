# This migration comes from auto (originally 20251024000001)
class CreateAutoTables < ActiveRecord::Migration[8.0]
  def change
    # Executions - track workflow execution instances
    create_table :auto_executions do |t|
      t.string :workflow_id, null: false      # References YAML workflow definition
      t.integer :status, default: 0, null: false
      t.references :subject, polymorphic: true, null: true  # What triggered this (User, Project, etc)
      t.json :context, default: {}            # Workflow execution context/variables
      t.string :current_node_id                # Current node in YAML workflow
      t.datetime :started_at
      t.datetime :completed_at
      
      t.timestamps
      
      t.index :workflow_id
      t.index :status
      t.index [:subject_type, :subject_id]
    end
    
    # NodeExecutions - join table tracking job executions for each workflow step
    create_table :auto_node_executions do |t|
      t.references :execution, null: false, foreign_key: { to_table: :auto_executions }
      t.bigint :parent_id                     # For nested/loop executions
      t.string :node_id, null: false          # Node ID from YAML
      t.integer :node_index, null: false      # Execution order
      t.integer :status, default: 0, null: false
      t.integer :selection, default: 0        # Which path was taken (success/error/loop/etc)
      t.string :job_id                        # SolidQueue job ID
      t.string :job_class                     # Which job class executed this
      t.json :result, default: {}             # Job execution result
      t.text :error_details
      t.datetime :started_at
      t.datetime :completed_at
      
      t.timestamps
      
      t.index [:execution_id, :node_index], unique: true
      t.index :parent_id
      t.index :node_id
      t.index :job_id
      t.index :status
    end
    
    add_foreign_key :auto_node_executions, :auto_node_executions, column: :parent_id
  end
end


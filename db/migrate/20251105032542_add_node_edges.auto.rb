# frozen_string_literal: true

# This migration comes from auto (originally 20251105020002)
# Add proper graph edges - nodes can have MULTIPLE parents (true graph, not tree)
# 
# This is critical for merge nodes which have multiple incoming edges (one per branch)
# 
# Example:
#   parallel_node
#   ├─ branch_0 → ... → leaf_0 ──┐
#   ├─ branch_1 → ... → leaf_1 ──┼─→ merge_node
#   └─ branch_2 → ... → leaf_2 ──┘
#
# merge_node has 3 incoming edges (3 parents)
class AddNodeEdges < ActiveRecord::Migration[8.0]
  def change
    create_table :auto_node_edges do |t|
      t.bigint :from_node_id, null: false
      t.bigint :to_node_id, null: false
      t.timestamps
      
      t.index [:from_node_id, :to_node_id], unique: true
      t.index :to_node_id  # For reverse lookups (incoming edges)
    end
    
    add_foreign_key :auto_node_edges, :auto_nodes, column: :from_node_id
    add_foreign_key :auto_node_edges, :auto_nodes, column: :to_node_id
    
    # Keep parent_node_id for tree visualization, but edges are source of truth
    # parent_node_id will point to the "primary" parent (for UI/debugging)
    
    puts "✓ Added auto_node_edges table for true graph structure"
    puts "✓ Nodes can now have multiple parents (proper DAG)"
    puts "✓ Merge nodes will have multiple incoming edges"
  end
end


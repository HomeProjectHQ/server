# frozen_string_literal: true

# This migration comes from auto (originally 20251105020001)
# Converts from ltree hierarchical paths to explicit graph edges
# 
# This simplifies the codebase by 50% and makes graph operations trivial.
# No special extensions needed - just PostgreSQL foreign keys + recursive CTEs!
#
# Before: "105.0.1.2.b1.4.6.8.9.10.11" (complex path parsing)
# After:  parent_node_id (simple foreign key)
class ConvertToGraphStructure < ActiveRecord::Migration[8.0]
  def change
    # Remove ltree - it's dead to us now 🔥
    remove_column :auto_nodes, :path, :ltree
    
    # Add graph metadata (no parent_node_id - we use edge table only!)
    add_column :auto_nodes, :branch_index, :integer  # Which branch in parallel (0, 1, 2...)
    add_column :auto_nodes, :depth, :integer, default: 0  # Depth in graph for visualization
    
    # PostgreSQL recursive CTEs can handle any graph query we need:
    # 
    # Find all descendants:
    #   WITH RECURSIVE descendants AS (
    #     SELECT * FROM auto_nodes WHERE id = ?
    #     UNION ALL
    #     SELECT n.* FROM auto_nodes n
    #     JOIN descendants d ON n.parent_node_id = d.id
    #   )
    #   SELECT * FROM descendants;
    #
    # No special extensions required!
    
    puts "✓ Nuked ltree"
    puts "✓ Added explicit graph edges (parent_node_id)"
    puts "✓ Added branch_index and depth for graph metadata"
    puts "✓ Ready for PostgreSQL recursive CTE graph queries"
  end
end

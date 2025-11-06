# Auto Workflow Monitoring - Quick Start

## Simplest Option: Direct Grep

```bash
# Monitor milestones only (clean output, no SQL noise)
tail -f log/development.log | grep -E '\[Auto::Node\] ✓|\[Auto::Scheduler\] ▶|\[Auto::Scheduler\] ■|\[Scheduler\] Cycle:'

# With colors
tail -f log/development.log | grep --color=always -E '\[Auto::Node\] ✓|\[Auto::Scheduler\] ▶|\[Auto::Scheduler\] ■|\[Scheduler\] Cycle:'

# Filter for specific workflow
tail -f log/development.log | grep -E '\[Auto::Node\] ✓|\[Scheduler\] Cycle:' | grep scan_new_media

# Show everything Auto-related (includes SQL, more verbose)
tail -f log/development.log | grep -E '\[Auto::'
```

## Using the Auto-Logs Script

```bash
# From your Rails app directory
bin/auto-logs

# Filter for specific workflow
bin/auto-logs scan_new_media
```

## What You'll See

With the new logging format, you'll see clean milestone logs:

```
[Auto::Scheduler] ▶ Started workflow scan_new_media (#103)
[Auto::Node] ✓ media_folder_loop (#127515) completed → loop [workflow: scan_new_media #103]
[Auto::Node] ✓ ls_movies (#127516) completed → default [workflow: scan_new_media #103]
[ParallelJob] Preparing to spawn 3 parallel branches
[Auto::Scheduler] Created 3 branches for parallel movies
[Auto::Node] ✓ find_movie_by_path (#127518) completed → default [workflow: scan_new_media #103]
[Auto::MergeJob] Merge all_movies_imported (#127522) waiting for 3 branches from parallel movies (#127517)
[Auto::MergeJob] Convergence: 2/3 branches complete
[Auto::MergeJob] Convergence: 3/3 branches complete
[Auto::MergeJob] ✓ All branches converged, proceeding
[Auto::Node] ✓ all_movies_imported (#127522) completed → default [workflow: scan_new_media #103]
[Auto::Scheduler] ■ Completed workflow scan_new_media (#103) - 150 nodes executed
```

## Key Symbols

- `▶` - Workflow started
- `✓` - Node completed successfully
- `■` - Workflow completed

## Rails Console Monitoring

```ruby
# Check active workflows
Auto::Workflow.active.each do |w|
  puts "#{w.workflow_id} (##{w.id}): #{w.nodes.count} nodes"
  puts "  needs_job: #{w.nodes.needs_job.count}"
  puts "  active: #{w.nodes.active_status.count}"
  puts "  complete: #{w.nodes.complete.count}"
end

# Watch specific workflow progress
workflow = Auto::Workflow.find(103)
workflow.nodes.order(created_at: :desc).limit(10).pluck(:node_id, :status)

# Find problems
Auto::Node.unhandled_job_failure.order(completed_at: :desc).limit(5).each do |n|
  puts "#{n.node_id}: #{n.error_details}"
end
```

## Debugging Verbose Output

The new logging removes the noisy "Resolved Args" debug output you were seeing.
It's now only logged at DEBUG level:

```ruby
# If you need to see args for debugging
Rails.logger.level = :debug

# Then watch logs
tail -f log/development.log | grep -E '\[Auto::'
```

## Noise Reduction

The refactored logging:

- ✅ Removes repetitive "Resolved Args" blocks
- ✅ Only shows milestone events by default (INFO level)
- ✅ Includes workflow context in every log line
- ✅ Uses symbols (▶✓■) for quick visual scanning
- ✅ Groups related info in single log lines

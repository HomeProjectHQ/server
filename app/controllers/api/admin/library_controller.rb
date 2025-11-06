module Api
  module Admin
    class LibraryController < ApplicationController
      # POST /api/admin/library/scan
      # Trigger a full media library scan across all enabled media folders
      def scan
        # Check if there are any enabled media folders
        if MediaFolder.enabled.empty?
          render json: {
            error: "No media folders configured or enabled",
            message: "Please add at least one media folder via /api/admin/media_folders"
          }, status: :unprocessable_entity
          return
        end
        
        # Queue the media scanner job (it will scan all enabled media folders)
        job = MediaScannerJob.perform_later
        
        render json: {
          job_id: job.job_id,
          message: "Library scan job queued successfully",
          media_folders: MediaFolder.enabled.pluck(:name, :path)
        }, status: :accepted
      end
      
      # GET /api/admin/library/scan_status
      # Get the status of background jobs
      def scan_status
        # Get job statistics from Solid Queue
        @jobs = {
          pending: SolidQueue::Job.where(finished_at: nil).count,
          completed: SolidQueue::Job.where.not(finished_at: nil).count,
          failed: SolidQueue::FailedExecution.count
        }
        
        # Get recent jobs
        @recent_jobs = SolidQueue::Job
          .order(created_at: :desc)
          .limit(10)
          .map do |job|
            {
              id: job.id,
              class_name: job.class_name,
              status: job.finished_at ? 'completed' : 'pending',
              created_at: job.created_at,
              finished_at: job.finished_at
            }
          end
      end
    end
  end
end



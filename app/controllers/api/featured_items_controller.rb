class Api::FeaturedItemsController < ApplicationController
  before_action :set_profile
  
  # GET /api/profiles/:id/featured?placement=hero
  # Get current featured items for a profile (optionally filtered by placement)
  def index
    placement = params[:placement]
    @featured_items = @profile.featured_items.current_for(@profile, placement: placement).limit(5)
    
    if @featured_items.any?
      render :index
    else
      render json: { message: "No current featured items available. Generate some first." }, status: :not_found
    end
  end
  
  # POST /api/profiles/:id/featured/generate
  # Generate new featured items for the profile
  def generate
    # Optional: specify placements to generate for
    placements = params[:placements] || ['hero']
    
    # Start the generate_featured_items workflow with profile as subject
    workflow = Auto::Workflow.create!(
      workflow_id: 'generate_featured_items',
      subject: @profile,
      args: { placements: placements }
    )
    
    # Wait for completion (or timeout after 30 seconds)
    timeout = 30.seconds.from_now
    until workflow.reload.completed? || workflow.failed? || Time.current > timeout
      sleep 0.5
    end
    
    if workflow.completed?
      @featured_items = @profile.featured_items.current.limit(5)
      render :index, status: :created
    elsif workflow.failed?
      render json: { 
        error: "Failed to generate featured items", 
        details: workflow.nodes.failed.first&.error_details 
      }, status: :unprocessable_entity
    else
      render json: { 
        error: "Featured item generation timed out",
        workflow_id: workflow.id,
        status: workflow.status
      }, status: :request_timeout
    end
  end
  
  # DELETE /api/profiles/:id/featured
  # Expire all current featured items (optionally filtered by placement)
  def destroy
    placement = params[:placement]
    featured_items = placement ? 
      @profile.featured_items.current.for_placement(placement) : 
      @profile.featured_items.current
    
    if featured_items.any?
      featured_items.each(&:expire!)
      head :no_content
    else
      render json: { error: "No current featured items to expire" }, status: :not_found
    end
  end
  
  # GET /api/profiles/:id/featured/history
  # Get featured item history for a profile
  def history
    placement = params[:placement]
    @featured_items = placement ?
      @profile.featured_items.recent.for_placement(placement).limit(20) :
      @profile.featured_items.recent.limit(20)
    render :index
  end
  
  private
  
  def set_profile
    @profile = Profile.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Profile not found" }, status: :not_found
  end
end


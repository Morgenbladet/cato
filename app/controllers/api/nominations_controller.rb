class Api::NominationsController < ApplicationController
  respond_to :json
  protect_from_forgery with: :null_session

  # GET /api/nominations
  def index
    @nominations = Nomination.all
    if params["institution"]
      @nominations = @nominations.where(institution_id: params["institution"])
    elsif params["search"]
      @nominations = @nominations.search(params['search'])
    end
  end

  # GET /api/nominations/1
  def show
    @nomination = Nomination.find(params["id"])
  rescue
    render json: { error: 'not found'}, status: :not_found
  end

  # GET /api/nominations/random
  def random
    @nominations = Nomination.ten_random
    render :index
  end

  # POST /api/nominations/1/vote
  def vote
    @nomination = Nomination.find(params["id"])
    Nomination.increment_counter(:votes, params["id"])
    render :show, status: :ok, location: api_nomination_path
  rescue
    render json: { error: 'not found' }, status: :not_found
  end
end

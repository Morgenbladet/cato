class NominationsController < ApplicationController
  before_action :set_nomination, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource # also loads @nomination[s]
  protect_from_forgery except: [:create, :vote]

  # GET /nominations
  # GET /nominations.json
  # GET /nominations[.json]?institution=1
  def index
    if params["institution"]
      @nominations = @nominations.where(institution_id: params["institution"])
    end
    
    @nominations = @nominations.order(:verified, :name)
  end

  # GET /nominations/1
  # GET /nominations/1.json
  def show
  end

  # GET /nominations/new
  def new
    @nomination = Nomination.new
  end

  # GET /nominations/1/edit
  def edit
  end

  # POST /nominations
  # POST /nominations.json
  def create
    @nomination = Nomination.new(nomination_params)
    @nomination.verified = false

    respond_to do |format|
      if @nomination.save
        format.html { redirect_to @nomination, notice: 'Nomination was successfully created.' }
        format.json { render :show, status: :created, location: @nomination }
      else
        format.html { render :new }
        format.json { render json: @nomination.errors.full_messages.join(";"), status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /nominations/1
  # PATCH/PUT /nominations/1.json
  def update
    respond_to do |format|
      if @nomination.update(nomination_params)
        format.html { redirect_to nominations_url, notice: 'Nomination was successfully updated.' }
        format.json { render :show, status: :ok, location: @nomination }
      else
        format.html { render :edit }
        format.json { render json: @nomination.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /nominations/1/vote.json
  def vote
    session[:voted_for] ||= []
    respond_to do |format|
      if session[:voted_for].include?(@nomination.id)
        format.json { render json: "Du har allerede stemt for denne", status: :unprocessable_entity }
        format.html { redirect_to nominations_url, notice: "Du har allerede stemt for denne" }
      else
        @nomination.increment(:votes)
        if @nomination.save
          session[:voted_for] << @nomination.id
          format.json { render :show, status: :ok, location: @nomination }
          format.html { redirect_to nominations_url, notice: "Stemmen er lagret" }
        else
          format.json { render json: "Kunne ikke lagre stemmen", status: :unprocessable_entity }
          format.html { redirect_to nominations_url, notice: "Kunne ikke lagre stemmen" }
        end
      end
    end
  end


  # DELETE /nominations/1
  # DELETE /nominations/1.json
  def destroy
    @nomination.destroy
    respond_to do |format|
      format.html { redirect_to nominations_url, notice: 'Nomination was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_nomination
      @nomination = Nomination.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def nomination_params
      params.require(:nomination).permit(:institution_id, :name, :reason, :nominator, :nominator_email, :verified)
    end
end

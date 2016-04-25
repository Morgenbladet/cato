class NominationsController < ApplicationController
  before_action :set_nomination, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource # also loads @nomination[s]
  protect_from_forgery except: [:create, :vote]

  # GET /nominations
  # GET /nominations.json
  # GET /nominations[.json]?institution=1
  def index
    if params["sort"]
      @sort_params = params["sort"]
      @nominations = @nominations.sorted_by(params["sort"])
    else
      @sort_params = "name asc"
      @nominations = @nominations.order(name: 'asc')
    end

    if params["institution"]
      @nominations = @nominations.where(institution_id: params["institution"])
    end

    if params["search"]
      @nominations = @nominations.search(params['search'])
    end

    respond_to do |format|
      format.json
      format.html do
        @nominations = @nominations.page(params[:page])
        render :index
      end
    end
  end

  def shortlist
    if params["sort"]
      @sort_params = params["sort"]
      @nominations = @nominations.sorted_by(params["sort"])
    else
      @sort_params = "name asc"
      @nominations = @nominations.order(name: 'asc')
    end

    @nominations = @nominations.where(shortlisted: true).page(params[:page])
    @title = "Shortlist"
    render :index
  end

  # GET /nominations/random.json
  def random
    @nominations = @nominations.unscoped.ten_random
    respond_to do |format|
      format.json { render :index }
    end
  end

  # GET /nominations/full_report
  def full_report
    @nominations = @nominations.verified.order(:name)
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
    @nomination.reasons.each {|r| r.verified = false }

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

  # PATCH/PUT /nominations/merge
  def merge
    nom = Nomination.find(params["ids"])
    keeper = nom.shift
    nom.each do |n|
      keeper.eat!(n)
    end

    redirect_to keeper, notice: "#{nom.count + 1} records merged into one"
  rescue
    redirect_to nominations_url, notice: "An error occured during merge"
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
  
  # PATCH /nominations/verify_all
  def verify_all
    Reason.update_all(verified: true)
    redirect_to nominations_url, notice: 'All verified'
  rescue
    redirect_to nominations_url, notice: 'Error occured.'
  end

  # POST /nominations/1/vote.json
  def vote
    session[:voted_for] ||= []
    respond_to do |format|
      if session[:voted_for].include?(@nomination.id)
        format.json { render json: "Du har allerede stemt for denne", status: :unprocessable_entity }
        format.html { redirect_to nominations_url, notice: "Du har allerede stemt for denne" }
      else
        Nomination.increment_counter(:votes, @nomination.id)
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
      params.require(:nomination)
        .permit(:institution_id, :name, :gender, :branch, :year_of_birth,
                :shortlisted, :shortlist_reason, :documentation,
                reasons_attributes:
                  %i|id _destroy reason nominator nominator_email verified| )
    end
end

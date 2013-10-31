class ExternalResultsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  skip_load_resource only: [:create]

  before_filter :load_competition, :only => [:index, :create]

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  # GET /competitions/#/external_results
  def index
    @external_results = @competition.external_results
    @external_result = ExternalResult.new

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /external_results/1/edit
  def edit
    @external_result = ExternalResult.find(params[:id])
    @competition = @external_result.competition
  end

  # POST /external_results
  # POST /external_results.json
  def create
    @external_result = ExternalResult.new(external_result_params)

    respond_to do |format|
      if @external_result.save
        format.html { redirect_to competition_external_results_path(@competition), notice: 'External result was successfully created.' }
        format.json { render json: @external_result, status: :created, location: @external_result }
      else
        @external_results = @competition.external_results
        format.html { render action: "index" }
        format.json { render json: @external_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /external_results/1
  # PUT /external_results/1.json
  def update
    @external_result = ExternalResult.find(params[:id])
    @competition = @external_result.competition

    respond_to do |format|
      if @external_result.update_attributes(external_result_params)
        format.html { redirect_to competition_external_results_path(@competition), notice: 'External result was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @external_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /external_results/1
  # DELETE /external_results/1.json
  def destroy
    @external_result = ExternalResult.find(params[:id])
    @competition = @external_result.competitor.competition
    @external_result.destroy

    respond_to do |format|
      format.html { redirect_to competition_external_results_path(@competition) }
      format.json { head :no_content }
    end
  end

  private
  def external_result_params
    params.require(:external_result).permit(:competitor_id, :details, :rank)
  end
end

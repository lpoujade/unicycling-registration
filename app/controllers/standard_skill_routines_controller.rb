require 'csv'
class StandardSkillRoutinesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_new_standard_skill_routine, :only => [:create]
  load_and_authorize_resource
  before_filter :load_registrant, :only => [:create]

  def load_new_standard_skill_routine
    @routine = StandardSkillRoutine.new
  end

  def load_registrant
    @registrant = Registrant.find(params[:registrant_id])
  end

  # POST /registrants/:id/standard_skill_routines/
  def create
    authorize! :read, @registrant
    @routine.registrant = @registrant
    @routine.save!

    redirect_to standard_skill_routine_path(@routine), notice: 'Standard Skill Routine Successfully Started.' 
  end

  # GET /standard_skill_routines/:id
  def show
    @entries = @standard_skill_routine.standard_skill_routine_entries
    @entry = @standard_skill_routine.standard_skill_routine_entries.build()
    @total = @standard_skill_routine.total_skill_points

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @entries }
    end
  end

  # GET /standard_skill_routines
  def index
    @registrants = current_user.registrants
  end
end

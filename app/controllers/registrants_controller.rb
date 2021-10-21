# == Schema Information
#
# Table name: registrants
#
#  id                       :integer          not null, primary key
#  first_name               :string(255)
#  middle_initial           :string(255)
#  last_name                :string(255)
#  birthday                 :date
#  gender                   :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  user_id                  :integer
#  deleted                  :boolean          default(FALSE), not null
#  bib_number               :integer
#  wheel_size_id            :integer
#  age                      :integer
#  ineligible               :boolean          default(FALSE), not null
#  volunteer                :boolean          default(FALSE), not null
#  online_waiver_signature  :string(255)
#  access_code              :string(255)
#  sorted_last_name         :string(255)
#  status                   :string(255)      default("active"), not null
#  registrant_type          :string(255)      default("competitor")
#  rules_accepted           :boolean          default(FALSE), not null
#  online_waiver_acceptance :boolean          default(FALSE), not null
#
# Indexes
#
#  index_registrants_deleted             (deleted)
#  index_registrants_on_registrant_type  (registrant_type)
#  index_registrants_on_user_id          (user_id)
#

class RegistrantsController < ApplicationController
  include RegistrationHelper

  before_action :authenticate_user!, except: [:results]
  before_action :load_user, only: [:index]
  before_action :load_registrant_by_bib_number, only: %i[show results refresh_organization_status copy_to_competitor copy_to_noncompetitor destroy]
  before_action :authorize_registrant, only: %i[show destroy refresh_organization_status]
  before_action :authorize_logged_in, only: %i[all subregion_options]
  before_action :skip_authorization, only: [:results]

  before_action :set_registrants_breadcrumb
  before_action :set_single_registrant_breadcrumb, only: [:show]

  # GET /users/12/registrants
  def index
    authorize @user, :registrants?
    @my_registrants = @user.registrants.active_or_incomplete
    @shared_registrants = @user.accessible_registrants - @my_registrants
    @total_owing = @user.total_owing
    @has_print_waiver = @config.print_waiver?

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @registrants }
    end
  end

  def new
    @user = current_user
    @registrant = Registrant.new(user: @user)
    @registrant.registrant_type = params[:registrant_type]
    authorize @registrant
    if params[:copy_from_previous].nil?
      if previous_registrants_for(current_user).any?
        flash.now[:notice] = "We have found registrations from previous conventions."
        params[:copy_from_previous] = "true"
      else
        params[:copy_from_previous] = "false"
      end
    end

    @copy_from_previous = params[:copy_from_previous] == "true"
    @previous_registrant_options = previous_registrants_for(@user)
  end

  # GET /registrants/all
  def all
    @registrants = Registrant.includes(:contact_detail).active.order(:bib_number)

    respond_to do |format|
      format.html # all.html.erb
      format.pdf { render_common_pdf "all", 'Landscape' }
    end
  end

  # GET /registrants/1
  # GET /registrants/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render json: @registrant }
      format.pdf { render_common_pdf("show", "Portrait") }
    end
  end

  # GET /registrants/1/results
  def results
    @results = @registrant.results.awarded.includes(competitor: [:members, competition: :age_group_type]).select(&:use_for_awards?)
    respond_to do |format|
      format.html
    end
  end

  # DELETE /registrants/1
  # DELETE /registrants/1.json
  def destroy
    @registrant.deleted = true

    respond_to do |format|
      if @registrant.save
        format.html { redirect_to root_path, notice: 'Registrant deleted' }
        format.json { head :no_content }
      else
        format.html { redirect_to root_path, alert: "Error deleting registrant" }
      end
    end
  end

  # PUT /registrants/:id/refresh_organization_status
  def refresh_organization_status
    if @config.organization_membership_config.automated_checking?
      UpdateOrganizationMembershipStatusWorker.perform_async(@registrant.id)
    end
    render plain: "", status: :ok
  end

  def subregion_options
    render partial: 'subregion_select', locals: { from_object: false }
  end

  def copy_to_competitor
    authorize @registrant, :duplicate_registrant?
    @user = @registrant.user
    if DuplicateRegistrant.new(@registrant).to_competitor
      flash[:notice] = "Successfully created new competitor registrant. Go set up the events, expense items, and registration costs"
    else
      flash[:alert] = "Error creating new competitor registrant"
    end
    redirect_to user_registrants_path(@user)
  end

  def copy_to_noncompetitor
    authorize @registrant, :duplicate_registrant?
    @user = @registrant.user
    if DuplicateRegistrant.new(@registrant).to_noncompetitor
      flash[:notice] = "Successfully created new noncompetitor registrant. Go set up the expense items, and registration costs"
    else
      flash[:alert] = "Error creating new noncompetitor registrant"
    end
    redirect_to user_registrants_path(@user)
  end

  private

  def load_user
    @user = User.this_tenant.find(params[:user_id])
  end

  def load_registrant_by_bib_number
    @registrant = Registrant.find_by!(bib_number: params[:id])
  end

  def authorize_registrant
    authorize @registrant
  end

  def authorize_logged_in
    authorize current_user, :logged_in?
  end

  def set_registrants_breadcrumb
    add_breadcrumb t("my_registrants", scope: "breadcrumbs"), user_registrants_path(current_user) if current_user
  end

  def set_single_registrant_breadcrumb
    add_registrant_breadcrumb(@registrant)
  end
end

# == Schema Information
#
# Table name: registrant_group_types
#
#  id                    :integer          not null, primary key
#  source_element_type   :string           not null
#  source_element_id     :integer          not null
#  notes                 :string
#  max_members_per_group :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class RegistrantGroupTypesController < ApplicationController
  before_action :authenticate_user!

  before_action :load_registrant_group_type, except: %i[index new create]
  before_action :authorize_user, except: %i[index new create]
  before_action :authorize_collection, only: %i[index new]

  # GET /registrant_group_types
  def index
    @registrant_group_types = RegistrantGroupType.all
  end

  # GET /registrant_group_types/new
  def new
    @registrant_group_type = RegistrantGroupType.new
  end

  # GET /registrant_group_types/1
  def show
    @registrant_groups = @registrant_group_type.registrant_groups
  end

  # POST /registrant_group_types
  def create
    source_element = if params[:source_element_event].present?
                       Event.find(params[:source_element_event])
                     elsif params[:source_element_expense_item].present?
                       ExpenseItem.find(params[:source_element_expense_item])
                     end
    @registrant_group_type = RegistrantGroupType.new(registrant_group_type_params)
    @registrant_group_type.source_element = source_element
    authorize @registrant_group_type
    if @registrant_group_type.save
      redirect_to @registrant_group_type, notice: 'Registrant group type was successfully created.'
    else
      render :new
    end
  end

  # PUT /registrant_group_types/1
  def update
    if @registrant_group_type.update_attributes(registrant_group_type_params)
      redirect_to @registrant_group_type, notice: 'Registrant group type was successfully updated.'
    else
      render :show
    end
  end

  # DELETE /registrant_group_types/1
  def destroy
    @registrant_group_type.destroy

    redirect_to registrant_group_types_url
  end

  private

  def authorize_user
    authorize @registrant_group_type
  end

  def authorize_collection
    authorize RegistrantGroupType
  end

  def load_registrant_group_type
    @registrant_group_type = RegistrantGroupType.find(params[:id])
  end

  def registrant_group_type_params
    params.require(:registrant_group_type).permit(
      :notes,
      :max_members_per_group
    )
  end
end

# == Schema Information
#
# Table name: standard_skill_routines
#
#  id            :integer          not null, primary key
#  registrant_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_standard_skill_routines_on_registrant_id  (registrant_id) UNIQUE
#

require 'spec_helper'

describe StandardSkillRoutinesController do
  before do
    FactoryGirl.create(:event_configuration, standard_skill: true, standard_skill_closed_date: 1.week.from_now)
    @user = FactoryGirl.create(:user)
    @registrant = FactoryGirl.create(:competitor, user: @user)
    sign_in @user
  end

  describe "GET show" do
    it "assigns the requested routine as @standard_skill_routine" do
      routine = FactoryGirl.create(:standard_skill_routine, registrant: @registrant)
      get :show, id: routine.to_param
      expect(assigns(:standard_skill_routine)).to eq(routine)
      expect(assigns(:total)).to eq(0)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new routine" do
        expect do
          post :create, registrant_id: @registrant.to_param
        end.to change(StandardSkillRoutine, :count).by(1)
      end

      it "redirects to the created routine" do
        post :create, registrant_id: @registrant.to_param
        expect(response).to redirect_to(StandardSkillRoutine.last)
      end
    end

    describe "when a routine already exists" do
      let!(:standard_skill_routine) { FactoryGirl.create(:standard_skill_routine, registrant: @registrant) }

      it "redirects to that routine without creating a new one" do
        expect do
          post :create, registrant_id: @registrant.to_param
        end.not_to change(StandardSkillRoutine, :count)
        expect(response).to redirect_to(standard_skill_routine)
      end
    end

    it "Cannot create a routine for another user" do
      post :create, registrant_id: FactoryGirl.create(:registrant).to_param
      expect(response).to redirect_to(root_path)
    end

    describe "when standard skill is closed" do
      before(:each) do
        EventConfiguration.first.update_attribute(:standard_skill_closed_date, Date.yesterday)
      end

      it "cannot create a new routine" do
        post :create, registrant_id: @registrant.to_param
        expect(response).to redirect_to(root_path)
      end
    end
  end
end

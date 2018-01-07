# == Schema Information
#
# Table name: judges
#
#  id             :integer          not null, primary key
#  competition_id :integer
#  judge_type_id  :integer
#  user_id        :integer
#  created_at     :datetime
#  updated_at     :datetime
#  status         :string           default("active"), not null
#
# Indexes
#
#  index_judges_event_category_id                                (competition_id)
#  index_judges_judge_type_id                                    (judge_type_id)
#  index_judges_on_judge_type_id_and_competition_id_and_user_id  (judge_type_id,competition_id,user_id) UNIQUE
#  index_judges_user_id                                          (user_id)
#

require 'spec_helper'

describe JudgesController do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @super_admin = FactoryGirl.create(:super_admin_user)
    sign_in @super_admin
    @ev = FactoryGirl.create(:event)
    @ec = FactoryGirl.create(:competition, event: @ev)
    @data_entry_volunteer_user = FactoryGirl.create(:data_entry_volunteer_user)
    @judge_type = FactoryGirl.create(:judge_type, event_class: @ec.event_class)
    @other_judge_type = FactoryGirl.create(:judge_type, event_class: "Flatland")
  end

  # This should return the minimal set of attributes required to create a valid
  # EventsJudgeType. As you add validations to EventsJudgeType, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { judge_type_id: 1,
      user_id: @user.id }
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new EventJudgeType" do
        expect do
          post :create, params: { judge: valid_attributes, competition_id: @ec.id }
        end.to change(Judge, :count).by(1)
      end

      it "redirects to the events show page" do
        post :create, params: { judge: valid_attributes, competition_id: @ec.id }
        expect(response).to redirect_to(competition_judges_path(@ec))
      end
    end

    describe "with invalid params" do
      it "does not create a new judge" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Judge).to receive(:valid?).and_return(false)
        expect do
          post :create, params: { judge: { user_id: 1 }, competition_id: @ec.id }
        end.not_to change(Judge, :count)
      end

      it "re-renders the 'index' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Judge).to receive(:valid?).and_return(false)
        post :create, params: { judge: { user_id: 1 }, competition_id: @ec.id }

        assert_select "h1", "Manage #{@ec} Judges"
      end
    end
  end

  describe "POST copy_judges" do
    it "copies judges from event to event" do
      @new_competition = FactoryGirl.create(:competition)
      FactoryGirl.create(:judge, competition: @new_competition)

      expect(@ec.judges.count).to eq(0)

      post :copy_judges, params: { competition_id: @ec.id, copy_judges: { competition_id: @new_competition.id } }

      expect(@ec.judges.count).to eq(1)
    end

    it "fails to copy judges from a different type of competition" do
      competition = FactoryGirl.create(:distance_competition)
      judge_type = FactoryGirl.create(:judge_type, event_class: "High/Long")
      judge = FactoryGirl.create(:judge, judge_type: judge_type, competition: competition)

      post :copy_judges, params: { competition_id: @ec.id, copy_judges: { competition_id: judge.competition.id } }
      expect(@ec.judges.count).to eq(0)
      expect(flash[:alert]).to eq("Judge type Not valid for competition")
    end

    it "should fail when not an admin" do
      sign_out @super_admin
      sign_in @user

      @new_competition = FactoryGirl.create(:competition)
      FactoryGirl.create(:judge, competition: @new_competition)

      expect(@ec.judges.count).to eq(0)

      post :copy_judges, params: { competition_id: @ec.id, copy_judges: { competition_id: @new_competition } }
      expect(response).to redirect_to(root_path)
    end
  end

  describe "#toggle_status" do
    let(:judge) { FactoryGirl.create(:judge) }

    it "toggles the active status" do
      request.env["HTTP_REFERER"] = root_path
      put :toggle_status, params: { id: judge.id }
      expect(judge.reload).not_to be_active

      # toggle back
      request.env["HTTP_REFERER"] = root_path
      put :toggle_status, params: { id: judge.id }
      expect(judge.reload).to be_active
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested judge" do
      judge = FactoryGirl.create(:judge, competition: @ec)
      expect do
        delete :destroy, params: { id: judge.to_param, competition_id: @ec.id }
      end.to change(Judge, :count).by(-1)
    end

    it "redirects to the judges list" do
      judge = FactoryGirl.create(:judge, competition: @ec)
      delete :destroy, params: { id: judge.to_param, competition_id: @ec.id }
      expect(response).to redirect_to(competition_judges_path(@ec))
    end
  end

  describe "GET index" do
    it "displays all of the judges for all" do
      get :index, params: { competition_id: @ec }

      assert_select "form", url: copy_judges_competition_judges_path(@ec), method: "post" do
        assert_select "select#copy_judges_competition_id", name: "copy_judges[competition_id]"
      end
    end

    it "has a blank judge" do
      get :index, params: { competition_id: @ec }

      assert_select "form", action: competition_judges_path(@ec), method: "post" do
        assert_select "select#judge_judge_type_id", name: "judge[judge_type_id]"
        assert_select "select#judge_user_id", name: "judge[user_id]"
      end
    end
  end
end

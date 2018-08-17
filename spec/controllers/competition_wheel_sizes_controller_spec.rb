# == Schema Information
#
# Table name: competition_wheel_sizes
#
#  id            :integer          not null, primary key
#  registrant_id :integer
#  event_id      :integer
#  wheel_size_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_competition_wheel_sizes_on_registrant_id_and_event_id  (registrant_id,event_id) UNIQUE
#  index_competition_wheel_sizes_registrant_id_event_id         (registrant_id,event_id)
#

require 'spec_helper'

describe CompetitionWheelSizesController do
  let(:competition) { FactoryBot.create(:competition) }
  let(:user) { FactoryBot.create(:super_admin_user) }
  let(:registrant) { FactoryBot.create(:competitor) }

  before { sign_in user }

  describe "GET index" do
    it "renders" do
      get :index, params: { registrant_id: registrant.bib_number }
      expect(response).to be_success
    end
  end

  describe "POST create" do
    let(:valid_attributes) do
      {
        event_id: FactoryBot.create(:event).id,
        wheel_size_id: WheelSize.first.id
      }
    end

    it "creates a competition_wheel_size" do
      expect do
        post :create, params: { registrant_id: registrant.bib_number, competition_wheel_size: valid_attributes }
      end.to change(CompetitionWheelSize, :count).by(1)
    end
  end

  describe "DELETE destroy" do
    let!(:wheel_size) { FactoryBot.create(:competition_wheel_size, registrant: registrant) }

    it "removes the result" do
      expect do
        delete :destroy, params: { id: wheel_size.id, registrant_id: registrant.bib_number }
      end.to change(CompetitionWheelSize, :count).by(-1)
    end
  end
end

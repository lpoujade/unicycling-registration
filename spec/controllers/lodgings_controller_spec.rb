# == Schema Information
#
# Table name: lodgings
#
#  id          :integer          not null, primary key
#  position    :integer
#  name        :string           not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'spec_helper'

describe LodgingsController do
  before(:each) do
    @user = FactoryBot.create(:super_admin_user)
    sign_in @user
  end
  let(:competitor) { FactoryBot.create(:competitor) }
  let!(:lodging_day) { FactoryBot.create(:lodging_day) }

  describe "POST #create" do
    let(:params) do
      {
        lodging_room_option_id: lodging_day.lodging_room_option_id,
        check_in_day: lodging_day.date_offered.strftime("%Y/%m/%d"),
        check_out_day: (lodging_day.date_offered + 1.day).strftime("%Y/%m/%d")
      }
    end

    it "creates a new registrant expense item" do
      expect do
        post :create, params: { registrant_id: competitor.bib_number, lodging_form: params }
      end.to change(RegistrantExpenseItem, :count).by(1)
    end
  end
end

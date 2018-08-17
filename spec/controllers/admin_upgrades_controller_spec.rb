require 'spec_helper'

describe AdminUpgradesController do
  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
  end

  describe "GET new" do
    it "renders" do
      get :new
      expect(response).to be_success
    end
  end

  describe "POST create" do
    context "with incorrect code" do
      it "raises exception" do
        post :create, params: { access_code: "wrong" }
        expect(response).to redirect_to(root_path) # because not authorized
      end
    end

    context "with correct code" do
      it "upgrades user" do
        post :create, params: { access_code: "TEST_UPGRADE_CODE" }
        expect(user.reload).to have_role(:convention_admin)
      end
    end
  end
end

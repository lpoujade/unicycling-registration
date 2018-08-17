require 'spec_helper'

describe OrganizationMembershipsController do
  let(:user) { FactoryBot.create(:super_admin_user) }
  before do
    @config = FactoryBot.create(:event_configuration, :with_usa)
    sign_in user

    FactoryBot.create_list(:competitor, 5)
  end

  let(:registrant) { FactoryBot.create(:registrant) }
  let(:contact_detail) { registrant.contact_detail }

  describe "#index" do
    it "can list all members" do
      get :index
      expect(response).to be_success
    end
  end

  describe "#toggle_confirm" do
    context "when the user is not yet confirmed" do
      it "can confirm" do
        put :toggle_confirm, params: { id: registrant.id }
        expect(registrant.reload.contact_detail).to be_organization_membership_manually_confirmed
      end
      it "can confirm with JS" do
        put :toggle_confirm, params: { id: registrant.id, format: :js }
        expect(registrant.reload.contact_detail).to be_organization_membership_manually_confirmed
      end
    end

    context "when the user is a confirmed member" do
      before { contact_detail.update_attribute(:organization_membership_manually_confirmed, true) }

      it "can unconfirm" do
        put :toggle_confirm, params: { id: registrant.id }
        expect(registrant.reload.contact_detail).not_to be_organization_membership_manually_confirmed
      end
    end
  end

  describe "#update_number" do
    let(:new_member_number) { "10" }

    it "saves the membership number" do
      put :update_number, params: { id: registrant.id, membership_number: new_member_number }, format: :js
      expect(registrant.reload.contact_detail.organization_member_number).to eq new_member_number
    end
  end

  describe "#export" do
    it "outputs some rows" do
      get :export, format: 'xls'
      expect(response.content_type.to_s).to eq("application/vnd.ms-excel")
    end
  end

  describe "#refresh_usa_status" do
    it "returns success" do
      post :refresh_usa_status, params: { id: registrant.id }
      expect(response).to be_success
    end
  end
end

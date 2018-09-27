require 'spec_helper'

describe Admin::RegistrantsController do
  before do
    @user = FactoryBot.create(:user)
    sign_in @user
  end

  describe "with a super admin user" do
    before do
      sign_out @user
      @admin_user = FactoryBot.create(:super_admin_user)
      sign_in @admin_user
    end

    describe "GET manage_all" do
      it "displays all registrants" do
        registrant = FactoryBot.create(:competitor)
        other_reg = FactoryBot.create(:registrant)
        get :manage_all
        assert_select "td", registrant.first_name
        assert_select "td", other_reg.first_name
      end
    end

    describe "GET manage_one" do
      it "renders" do
        get :manage_one
        expect(response).to be_success
      end
    end

    describe "POST choose_one" do
      let(:summary) { "0" }
      let(:bib_number) { nil }
      let(:registrant_id) { nil }
      let(:registrant) { FactoryBot.create(:registrant) }

      before { request.env["HTTP_REFERER"] = root_path }

      before { post :choose_one, params: { bib_number: bib_number, registrant_id: registrant_id, summary: summary } }

      context "with a bib_number" do
        context "with a matching bib_number" do
          let(:bib_number) { registrant.bib_number }

          it "sends to the build path" do
            expect(response).to redirect_to(registrant_build_path(registrant, :add_name))
          end
        end
      end

      context "without a bib_number or registrant_id" do
        it "redirects to back" do
          expect(response).to redirect_to(root_path)
        end
      end

      context "with a registrant" do
        let(:registrant_id) { registrant.id }

        it "sends me to the registrant name build path" do
          expect(response).to redirect_to(registrant_build_path(registrant, :add_name))
        end

        context "when choosing summary mode" do
          let(:summary) { "1" }

          it "sends me to the show page" do
            expect(response).to redirect_to(registrant_path(registrant))
          end
        end
      end
    end

    describe "POST undelete" do
      before do
        FactoryBot.create(:registration_cost)
      end

      it "un-deletes a deleted registration" do
        registrant = FactoryBot.create(:competitor, deleted: true)
        post :undelete, params: { id: registrant.to_param }
        registrant.reload
        expect(registrant.deleted).to eq(false)
      end

      it "redirects to the root" do
        registrant = FactoryBot.create(:competitor, deleted: true)
        post :undelete, params: { id: registrant.to_param }
        expect(response).to redirect_to(manage_all_registrants_path)
      end

      describe "as a normal user" do
        before do
          @user = FactoryBot.create(:user)
          sign_in @user
        end

        it "Cannot undelete a user" do
          registrant = FactoryBot.create(:competitor, deleted: true)
          post :undelete, params: { id: registrant.to_param }
          registrant.reload
          expect(registrant.deleted).to eq(true)
        end
      end
    end
  end
end

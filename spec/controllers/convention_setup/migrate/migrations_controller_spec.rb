require 'spec_helper'

describe ConventionSetup::Migrate::MigrationsController do
  before do
    FactoryBot.create(:tenant, subdomain: "other")
    Apartment::Tenant.create "other"
    Apartment::Tenant.switch "other" do
      event = FactoryBot.create(:event)
      FactoryBot.create(:event_category, event: event)
      FactoryBot.create(:event_choice, event: event)
    end
  end

  describe "as an admin user" do
    before do
      user = FactoryBot.create(:super_admin_user)
      sign_in user
    end

    it "initially has no events" do
      expect(Event.count).to eq(0)
    end

    it "can copy the events" do
      post :create_events, params: { tenant: "other" }
      expect(Event.count).to eq(1)
    end
  end
end

require 'spec_helper'

describe Translations::EventConfigurationsController do
  let!(:event_configuration) { FactoryBot.create(:event_configuration) }
  let(:user) { FactoryBot.create(:convention_admin_user) }

  before { sign_in user }

  after { I18n.locale = :en }

  describe "#edit" do
    it "renders" do
      get :edit, params: { id: event_configuration.id }
      expect(response).to be_successful
    end
  end

  describe "#update" do
    let(:valid_attributes) do
      {
        translations_attributes: {
          "1" => {
            "id" => event_configuration.translations.first.id,
            "locale" => "en",
            "short_name" => "The Convention"
          },
          "2" => {
            "id" => "",
            "locale" => "fr",
            "short_name" => "Le Convention"
          }
        }
      }
    end

    it "renders" do
      put :update, params: { id: event_configuration.id, event_configuration: valid_attributes }
      expect(response).to redirect_to(edit_translations_event_configuration_path)
      I18n.locale = :fr
      expect(event_configuration.reload.short_name).to eq("Le Convention")
    end
  end
end

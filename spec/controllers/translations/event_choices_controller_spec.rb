require 'spec_helper'

describe Translations::EventChoicesController do
  let!(:event_choice) { FactoryBot.create(:event_choice) }
  let(:user) { FactoryBot.create(:convention_admin_user) }

  before { sign_in user }

  after { I18n.locale = :en }

  describe "#index" do
    it "renders" do
      get :index
      expect(response).to be_successful
    end
  end

  describe "#edit" do
    it "renders" do
      get :edit, params: { id: event_choice.id }
      expect(response).to be_successful
    end
  end

  describe "#update" do
    let(:valid_attributes) do
      {
        translations_attributes: {
          "1" => {
            "id" => event_choice.translations.first.id,
            "locale" => "en",
            "label" => "Team"
          },
          "2" => {
            "id" => "",
            "locale" => "fr",
            "label" => "Equipe"
          }
        }
      }
    end

    it "renders" do
      put :update, params: { id: event_choice.id, event_choice: valid_attributes }
      expect(response).to redirect_to(translations_event_choices_path)
      I18n.locale = :fr
      expect(event_choice.reload.label).to eq("Equipe")
    end
  end
end

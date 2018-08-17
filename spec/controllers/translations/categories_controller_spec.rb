require 'spec_helper'

describe Translations::CategoriesController do
  let!(:category) { FactoryBot.create(:category) }
  let(:user) { FactoryBot.create(:convention_admin_user) }

  before { sign_in user }

  after { I18n.locale = :en }

  describe "#index" do
    it "renders" do
      get :index
      expect(response).to be_success
    end
  end

  describe "#edit" do
    it "renders" do
      get :edit, params: { id: category.id }
      expect(response).to be_success
    end
  end

  describe "#update" do
    let(:valid_attributes) do
      {
        translations_attributes: {
          "1" => {
            "id" => category.translations.first.id,
            "locale" => "en",
            "name" => "Track Racing"
          },
          "2" => {
            "id" => "",
            "locale" => "fr",
            "name" => "Le Track"
          }
        }
      }
    end

    it "renders" do
      put :update, params: { id: category.id, category: valid_attributes }
      expect(response).to redirect_to(translations_categories_path)
      I18n.locale = :fr
      expect(category.reload.name).to eq("Le Track")
    end
  end
end

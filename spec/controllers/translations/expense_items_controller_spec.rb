require 'spec_helper'

describe Translations::ExpenseItemsController do
  let!(:expense_item) { FactoryBot.create(:expense_item) }
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
      get :edit, params: { id: expense_item.id }
      expect(response).to be_successful
    end
  end

  describe "#update" do
    let(:valid_attributes) do
      {
        translations_attributes: {
          "1" => {
            "id" => expense_item.translations.first.id,
            "locale" => "en",
            "name" => "T-Shirt"
          },
          "2" => {
            "id" => "",
            "locale" => "fr",
            "name" => "Le T-Shirt"
          }
        }
      }
    end

    it "renders" do
      put :update, params: { id: expense_item.id, expense_item: valid_attributes }
      expect(response).to redirect_to(translations_expense_items_path)
      I18n.locale = :fr
      expect(expense_item.reload.name).to eq("Le T-Shirt")
    end
  end
end

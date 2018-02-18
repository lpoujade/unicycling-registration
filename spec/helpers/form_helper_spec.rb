require 'spec_helper'

describe FormHelper do
  let(:competition) { FactoryBot.create :competition }
  let!(:registrant) { FactoryBot.create(:competitor) }

  describe "#non_signed_up_registrant_select_box" do
    it "includes all registrants" do
      expect(helper.non_signed_up_registrant_select_box(competition)).to include("value=\"#{registrant.id}\"")
    end
  end
end

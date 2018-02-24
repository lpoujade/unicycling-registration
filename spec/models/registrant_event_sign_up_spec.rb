# == Schema Information
#
# Table name: registrant_event_sign_ups
#
#  id                :integer          not null, primary key
#  registrant_id     :integer
#  signed_up         :boolean          default(FALSE), not null
#  event_category_id :integer
#  created_at        :datetime
#  updated_at        :datetime
#  event_id          :integer
#
# Indexes
#
#  index_registrant_event_sign_ups_event_category_id              (event_category_id)
#  index_registrant_event_sign_ups_event_id                       (event_id)
#  index_registrant_event_sign_ups_on_registrant_id_and_event_id  (registrant_id,event_id) UNIQUE
#  index_registrant_event_sign_ups_registrant_id                  (registrant_id)
#

require 'spec_helper'

describe RegistrantEventSignUp do
  let(:re) { FactoryBot.create(:registrant_event_sign_up) }

  it "is valid from FactoryBot" do
    expect(re.valid?).to eq(true)
  end

  it "requires a registrant" do
    re.registrant = nil
    expect(re.valid?).to eq(false)
  end

  describe "when I sign up for an event which has an expense_item" do
    let(:expense_item) { FactoryBot.create(:expense_item) }
    let!(:event) { FactoryBot.create(:event, expense_item: expense_item) }
    let!(:reg) { FactoryBot.create(:competitor) }

    def sign_up
      @registrant_event_sign_up = FactoryBot.create(:registrant_event_sign_up, registrant: reg, event: event, event_category: event.event_categories.first)
    end
    it "creates a registrant_expense_item" do
      expect { sign_up }.to change(RegistrantExpenseItem, :count).by(1)
      expect(reg.reload).to have_expense_item(expense_item)
    end

    describe "when I have already signed-up for that event" do
      before { sign_up }

      it "when I un-sign-up, it removes the registrant_expense_item" do
        expect do
          @registrant_event_sign_up.update(signed_up: false, event_category: nil)
        end.to change(RegistrantExpenseItem, :count).by(-1)
      end
    end
  end

  describe "when an auto-competitor event exists" do
    before :each do
      @competition = FactoryBot.create(:competition)
      @competition_source = FactoryBot.create(:competition_source, target_competition: @competition, event_category: re.event_category)
    end

    it "doesn't add the competition on change of state if the competition isn't auto-creation" do
      re.signed_up = false
      expect(re.save).to be_truthy

      re.signed_up = true
      expect do
        expect(re.save).to be_truthy
      end.to change(Competitor, :count).by(0)
    end
  end

  describe "when a competitor already exists and I un-sign up" do
    before :each do
      @competition = FactoryBot.create(:competition, num_members_per_competitor: "One")
      @competition_source = FactoryBot.create(:competition_source, target_competition: @competition, event_category: re.event_category)
      @competitor = FactoryBot.create(:event_competitor, competition: @competition)
      @member = @competitor.members.first
      @member.update_attributes(registrant: re.registrant)
      re.reload
    end

    it "marks the member as dropped when I un-sign up for the competition" do
      re.signed_up = false
      re.save
      expect(@member.reload).to be_dropped_from_registration
    end

    it "marks the competitor as withdrawn if this is the only member" do
      re.signed_up = false
      re.save
      expect(@competitor.reload.status).to eq("withdrawn")
    end

    describe "When the event has multiple categories" do
      before :each do
        @event = re.event_category.event
        @cat2 = FactoryBot.create(:event_category, event: @event)
      end

      it "marks the member as dropped when I change the category I signed up for" do
        re.event_category = @cat2
        re.save
        expect(@member.reload).to be_dropped_from_registration
      end
    end
  end
end

describe "when a competition exists before a sign-up" do
  let(:event_category) { FactoryBot.create(:event).event_categories.first }
  before :each do
    @competition = FactoryBot.create(:competition, automatic_competitor_creation: true, num_members_per_competitor: "One")
    @competition_source = FactoryBot.create(:competition_source, target_competition: @competition, event_category: event_category)
  end

  it "adds the competition on change of state" do
    @re = FactoryBot.create(:registrant_event_sign_up, event: event_category.event, signed_up: false)
    expect do
      expect(@re.save).to be_truthy
    end.to change(Competitor, :count).by(0)

    @re.signed_up = true
    expect do
      expect(@re.save).to be_truthy
    end.to change(Competitor, :count).by(1)

    expect(Competitor.last.status).to eq("active")
  end

  describe "but the gender filter is in effect" do
    before :each do
      @competition_source.update_attribute(:gender_filter, "Female")
    end

    it "doesn't add the competitor on change of state" do
      @re = FactoryBot.create(:registrant_event_sign_up, event: event_category.event, signed_up: false)
      expect(@re.registrant.gender).to eq("Male")

      @re.signed_up = true
      expect do
        expect(@re.save).to be_truthy
      end.to change(Competitor, :count).by(0)
    end
  end
end

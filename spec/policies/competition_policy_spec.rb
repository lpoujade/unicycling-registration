require "spec_helper"

describe CompetitionPolicy do
  let(:competition) { FactoryGirl.create(:competition) }

  subject { described_class }

  permissions :manage_lane_assignments? do
    it "denies access to normal user" do
      expect(subject).not_to permit(FactoryGirl.create(:user), competition)
    end

    it "grants access to super_admin" do
      expect(subject).to permit(FactoryGirl.create(:super_admin_user), competition)
    end

    it "grants access to race official for this competition" do
      user = FactoryGirl.create(:user)
      user.add_role :race_official, competition
      expect(subject).to permit(user, competition)
    end
  end

  permissions :show? do
    describe "as data_entry volunteer" do
      let(:user) { FactoryGirl.create(:data_entry_volunteer_user) }

      it "is accessible" do
        expect(subject).to permit(user, competition)
      end
    end

    describe "as normal user" do
      it { expect(subject).not_to permit(FactoryGirl.create(:user), competition) }
    end
  end
end

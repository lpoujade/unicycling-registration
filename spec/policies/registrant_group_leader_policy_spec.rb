require "spec_helper"

describe RegistrantGroupLeaderPolicy do
  let(:super_admin) { FactoryBot.create(:super_admin_user) }

  let(:event_director) { FactoryBot.create(:user) }
  let(:other_event_director) { FactoryBot.create(:user) }
  let(:event) { FactoryBot.create(:event) }

  before do
    event_director.add_role(:director, event)
    other_event_director.add_role(:director, FactoryBot.create(:event))
  end
  let(:registrant_group_type) { FactoryBot.create(:registrant_group_type, source_element: event) }
  let(:registrant_group) { FactoryBot.create(:registrant_group, registrant_group_type: registrant_group_type) }
  let(:group_leader) { FactoryBot.create(:registrant_group_leader, registrant_group: registrant_group) }
  let(:registrant_group_leader) { FactoryBot.create(:registrant_group_leader, registrant_group: registrant_group) }

  subject { described_class }

  permissions :create?, :destroy? do
    it "super_admin can access" do
      expect(subject).to permit(super_admin, registrant_group_leader)
    end

    it "event director can access" do
      expect(subject).to permit(event_director, registrant_group_leader)
    end

    it "other director cannot access" do
      expect(subject).not_to permit(other_event_director, registrant_group_leader)
    end

    it "group leader can access" do
      expect(subject).to permit(group_leader.user, registrant_group_leader)
    end
  end
end

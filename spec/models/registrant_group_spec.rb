# == Schema Information
#
# Table name: registrant_groups
#
#  id                       :integer          not null, primary key
#  name                     :string
#  created_at               :datetime
#  updated_at               :datetime
#  registrant_group_type_id :integer
#
# Indexes
#
#  index_registrant_groups_on_registrant_group_type_id  (registrant_group_type_id)
#

require 'spec_helper'

describe RegistrantGroup do
  before(:each) do
    @rg = FactoryBot.create(:registrant_group)
  end

  it "has a valid factory" do
    expect(@rg.valid?).to eq(true)
  end

  it "name is optional" do
    @rg.name = nil
    expect(@rg.valid?).to eq(true)
  end

  context "with an existing registrant_group" do
    let!(:reg_group) { FactoryBot.create(:registrant_group, name: "My Name") }
    it "does not allow the same name again" do
      new_reg_group = FactoryBot.build(:registrant_group, registrant_group_type: reg_group.registrant_group_type, name: "My Name")
      expect(new_reg_group).to be_invalid
    end
  end

  it "has multiple registrant_group_members" do
    FactoryBot.create(:registrant_group_member, registrant_group: @rg)
    FactoryBot.create(:registrant_group_member, registrant_group: @rg)
    FactoryBot.create(:registrant_group_member, registrant_group: @rg)
    expect(@rg.registrant_group_members.count).to eq(3)
  end

  it "can assign a registrant to the leader" do
    @leader = FactoryBot.create(:registrant_group_leader, registrant_group: @rg)
    @rg.reload
    expect(@rg.registrant_group_leaders).to eq([@leader])
  end

  it "can be found via the registrant" do
    @rgm = FactoryBot.create(:registrant_group_member, registrant_group: @rg)
    @reg = @rgm.registrant
    expect(@reg.registrant_groups).to eq([@rg])
  end
end

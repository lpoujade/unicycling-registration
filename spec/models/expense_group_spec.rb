# == Schema Information
#
# Table name: expense_groups
#
#  id                     :integer          not null, primary key
#  visible                :boolean          default(TRUE), not null
#  position               :integer
#  created_at             :datetime
#  updated_at             :datetime
#  info_url               :string
#  competitor_required    :boolean          default(FALSE), not null
#  noncompetitor_required :boolean          default(FALSE), not null
#  registration_items     :boolean          default(FALSE), not null
#  info_page_id           :integer
#  system_managed         :boolean          default(FALSE), not null
#

require 'spec_helper'

describe ExpenseGroup do
  let(:group) { FactoryBot.create(:expense_group) }

  it "can be created by the factory" do
    expect(group).to be_valid
  end

  it "must have a name" do
    group.group_name = nil
    expect(group).not_to be_valid
  end

  it "must have a visible setting of true or false" do
    group.visible = nil
    expect(group).to be_invalid

    group.visible = true
    expect(group).to be_valid
  end

  it "cannot have both the info_page_id and info_url set" do
    group.info_page = FactoryBot.create(:page)
    group.info_url = "http://www.google.com"
    expect(group).to be_invalid
  end

  it "can have the info_page_id set" do
    group.info_page = FactoryBot.create(:page)
    expect(group).to be_valid
  end

  it "has a nice to_s" do
    expect(group.to_s).to eq(group.group_name)
  end

  it "onlies list the visible groups" do
    @group2 = FactoryBot.create(:expense_group, visible: true)
    group # reference to build it
    described_class.visible == [group]
  end

  it "defaults to not required" do
    group = described_class.new
    expect(group.competitor_required).to eq(false)
    expect(group.noncompetitor_required).to eq(false)
  end

  it "requires that the 'required' fields be set" do
    group.competitor_required = nil
    expect(group).to be_invalid

    group.competitor_required = false
    group.noncompetitor_required = nil
    expect(group).to be_invalid
  end

  describe "with expense_items" do
    before do
      @item2 = FactoryBot.create(:expense_item, expense_group: group)
      @item1 = FactoryBot.create(:expense_item, expense_group: group)
      @item2.update_attribute(:position, 2)
    end

    it "orders the items by position" do
      expect(group.expense_items).to eq([@item1, @item2])
    end
  end

  describe "with multiple expense groups" do
    before do
      group.position = 1
      group.visible = false
      group.save
      @group3 = FactoryBot.create(:expense_group)
      @group2 = FactoryBot.create(:expense_group)
      @group4 = FactoryBot.create(:expense_group)
      @group3.update(position: 3)
    end

    it "lists them in order" do
      expect(described_class.all).to eq([group, @group2, @group3, @group4])
    end

    it "lists the 'visible' ones in order" do
      expect(described_class.visible).to eq([@group2, @group3, @group4])
    end
  end
end

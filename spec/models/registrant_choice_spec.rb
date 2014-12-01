# == Schema Information
#
# Table name: registrant_choices
#
#  id              :integer          not null, primary key
#  registrant_id   :integer
#  event_choice_id :integer
#  value           :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#
# Indexes
#
#  index_registrant_choices_event_choice_id                       (event_choice_id)
#  index_registrant_choices_on_registrant_id_and_event_choice_id  (registrant_id,event_choice_id) UNIQUE
#  index_registrant_choices_registrant_id                         (registrant_id)
#

require 'spec_helper'

describe RegistrantChoice do
  before(:each) do
    @rc = FactoryGirl.create(:registrant_choice)
  end
  it "is valid from FactoryGirl" do
    @rc.valid?.should == true
  end
  it "requires an event_choice" do
    @rc.event_choice = nil
    @rc.valid?.should == false
  end

  it "requires a registrant" do
    @rc.registrant = nil
    @rc.valid?.should == false
  end

  it "determines if it has a value" do
    @rc.has_value?.should == false
  end

  it "cannot have 2 choices for the same event_choice" do
    @rc = FactoryGirl.build(:registrant_choice, :event_choice => @rc.event_choice, :registrant => @rc.registrant)
    @rc.valid?.should == false
  end

  describe "when a boolean has a value 1" do
    before(:each) do
      @rc.value = "1"
      @rc.save
    end
    it "has_value" do
      @rc.has_value?.should == true
    end
  end
  describe "when a multiple input has a value" do
    before(:each) do
      @ec = @rc.event_choice
      @ec.cell_type = "multiple"
      @ec.multiple_values = "hello,goodbye"
      @ec.save!
    end
    it "has_value with a selection" do
      @rc.value = "hello"
      @rc.save!
      @rc.has_value?.should == true
    end
    it "has no value when blank" do
      @rc.value = ""
      @rc.save!
      @rc.has_value?.should == false
    end
  end

  describe "when a text input has a value" do
    before(:each) do
      @ec = @rc.event_choice
      @ec.cell_type = "text"
      @ec.save!
    end
    it "has_value with anything" do
      @rc.value = "hi"
      @rc.has_value?.should == true
    end
    it "has no value with blank" do
      @rc.value = ""
      @rc.has_value?.should == false
    end
  end

  describe "When a best_time input has a value" do
    before(:each) do
      @ec = @rc.event_choice
      @ec.cell_type = "best_time"
      @ec.save!
    end
    it "has_value with anything" do
      @rc.value = "3:00"
      @rc.has_value?.should == true
      @rc.valid?.should == true
    end
    it "has no value with blank" do
      @rc.value = ""
      @rc.has_value?.should == false
      @rc.valid?.should == true
    end
    it "accepts numbers with :'s" do
      @rc.value = "1:23:45"
      @rc.has_value?.should == true
      @rc.valid?.should == true
    end
    it "doesn't accept numbers without signs" do
      @rc.value = "12345"
      @rc.valid?.should == false
    end
  end
end

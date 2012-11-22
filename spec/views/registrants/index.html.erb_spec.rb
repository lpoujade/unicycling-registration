require 'spec_helper'

describe "registrants/index" do
  before(:each) do
    assign(:registrants, [
      FactoryGirl.create(:registrant,
        :first_name => "Robin",
        :middle_initial => "A",
        :last_name => "Dunlop"
      ),
      FactoryGirl.create(:registrant,
        :first_name => "Caitlin",
        :middle_initial => "E",
        :last_name => "Goeres"
      )
    ])
  end

  it "renders a list of registrants" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "span", :text => "Robin Dunlop".to_s, :count => 1
    assert_select "span", :text => "Caitlin Goeres".to_s, :count => 1
  end
end

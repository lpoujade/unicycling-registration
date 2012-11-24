require 'spec_helper'

describe "registrants/show" do
  before(:each) do
    @registrant = FactoryGirl.create(:registrant, :birthday => Date.new(2012, 01, 05))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/#{@registrant.first_name}/)
    rendered.should match(/#{@registrant.last_name}/)
    rendered.should match(/#{@registrant.gender}/)
    rendered.should match(/05-Jan-2012/)
    rendered.should match(/#{@registrant.address_line_1}/)
    rendered.should match(/#{@registrant.address_line_2}/)
    rendered.should match(/#{@registrant.city}/)
    rendered.should match(/#{@registrant.state}/)
    rendered.should match(/#{@registrant.country}/)
    rendered.should match(/#{@registrant.zip_code}/)
    rendered.should match(/#{@registrant.phone}/)
    rendered.should match(/#{@registrant.mobile}/)
    rendered.should match(/#{@registrant.email}/)
  end
end

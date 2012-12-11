require 'spec_helper'

describe "categories/index" do
  before(:each) do
    @categories = [FactoryGirl.create(:category, :name => "Cat1"),
      FactoryGirl.create(:category, :name => "Cat2")]
    @category = Category.new
  end

  it "renders a list of categories" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Cat1".to_s, :count => 1
    assert_select "tr>td", :text => "Cat2".to_s, :count => 1
  end
end

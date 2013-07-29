require 'spec_helper'

describe "import_results/edit" do
  before(:each) do
    @import_result = assign(:import_result, FactoryGirl.create(:import_result))
  end

  it "renders the edit import_result form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => import_result_path(@import_result), :method => "post" do
      assert_select "input#import_result_raw_data", :name => "import_result[raw_data]"
      assert_select "input#import_result_bib_number", :name => "import_result[bib_number]"
      assert_select "input#import_result_minutes", :name => "import_result[minutes]"
      assert_select "input#import_result_seconds", :name => "import_result[seconds]"
      assert_select "input#import_result_thousands", :name => "import_result[thousands]"
      assert_select "input#import_result_disqualified", :name => "import_result[disqualified]"
    end
  end
end

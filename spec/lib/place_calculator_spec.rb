require 'spec_helper'

describe PlaceCalculator do
  describe "when calculating the placing of a few entries" do
    before(:each) do
      @calc = PlaceCalculator.new
    end

    it "should return DQ as place 0" do
      @calc.place_next(1,true).should == "DQ"
    end

    it "should place ascending times as ascending places" do
      @calc.place_next(1,false).should == 1
      @calc.place_next(10,false).should == 2
      @calc.place_next(100,false).should == 3
    end
    it "should place multiple times as ties" do
      @calc.place_next(1,false).should == 1
      @calc.place_next(1,false).should == 1
      @calc.place_next(10,false).should == 3
    end

    it "places an ineligible non-tie as a tie for the next competitor" do
      @calc.place_next(1,false).should == 1
      @calc.place_next(10,false).should == 2
      @calc.place_next(100,false, true).should == 3 #ineligible
      @calc.place_next(1000,false).should == 3 #like-a-tie
      @calc.place_next(10000,false).should == 4 #not 5, because not really a tie
    end

    it "places an ineligible tie as a normal non-place-taking-tie (ineligible second)" do
      @calc.place_next(1, false).should == 1
      @calc.place_next(1, false, true).should == 1
      @calc.place_next(2, false).should == 2
    end
    it "places an ineligible tie as a normal non-place-taking-tie (ineligible first)" do
      @calc.place_next(1, false, true).should == 1
      @calc.place_next(1, false).should == 1
      @calc.place_next(2, false).should == 2
    end
    # XXX
    #it "places 2 ineligibles who come in near each other a separate ranks" do
      #@calc.place_next(1, false, true).should == 1
      #@calc.place_next(2, false, true).should == 2
      #@calc.place_next(3, false).should == 1
      #@calc.place_next(4, false).should == 2
      #@calc.place_next(5, false, true).should == 3
      #@calc.place_next(6, false).should == 3
    #end

  end
end

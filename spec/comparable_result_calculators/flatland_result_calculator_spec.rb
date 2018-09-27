require 'spec_helper'

describe FlatlandResultCalculator do
  describe "when calculating the placement points of an event" do
    before do
      @competition = FactoryBot.create(:flatland_competition)
      @comp1 = FactoryBot.create(:event_competitor, competition: @competition)
      @jt = FactoryBot.create(:judge_type, event_class: "Flatland")
      @judge = FactoryBot.create(:judge, competition: @competition, judge_type: @jt)
      @calc = described_class.new
      allow(@comp1).to receive(:has_result?).and_return(true)
    end

    describe "when there are scores" do
      before do
        @score1_1 = double(:score, total: 11, val_4: 1)
        @score1_2 = double(:score, total: 9, val_4: 3)
      end

      it "has 0.0 for the total placing points, after subtracting high and low (only 2 judges)" do
        allow(@comp1).to receive(:scores).and_return([@score1_1, @score1_2])
        expect(@calc.competitor_comparable_result(@comp1)).to eq(0.0)
      end

      describe "with a 3rd judge's scores" do
        before do
          @judge3 = FactoryBot.create(:judge, competition: @competition, judge_type: @jt)
          @score1_3 = double(:score, total: 10, val_4: 5)

          allow(@comp1).to receive(:scores).and_return([@score1_1, @score1_2, @score1_3])
        end

        it "has non-zero placing points" do
          expect(@calc.competitor_comparable_result(@comp1)).to eq(10) # 11,9,10 (remain: 10)
        end

        describe "when checking a tie" do
          it "drops the high-low of the 'Total' and returns the val_4" do
            expect(@calc.competitor_tie_break_comparable_result(@comp1)).to eq(5)
          end
        end
      end
    end
  end
end

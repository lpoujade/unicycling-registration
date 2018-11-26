# == Schema Information
#
# Table name: wheel_sizes
#
#  id          :integer          not null, primary key
#  position    :integer
#  description :string
#  created_at  :datetime
#  updated_at  :datetime
#

require 'spec_helper'

describe WheelSize do
  context "with 1 wheel size" do
    before do
      @ws = FactoryBot.create(:wheel_size)
    end

    it "is valid" do
      expect(@ws.valid?).to eq(true)
    end

    it "requires a position" do
      @ws.position = nil
      expect(@ws.valid?).to eq(false)
    end

    it "requires a description" do
      @ws.description = nil
      expect(@ws.valid?).to eq(false)
    end

    it "returns the wheel sizes in position order" do
      @ws3 = FactoryBot.create(:wheel_size, position: 3)
      @ws2 = FactoryBot.create(:wheel_size, position: 2)
      expect(described_class.all).to eq([@ws3, @ws2, @ws])
    end

    it "returns the description as the to_s" do
      expect(@ws.to_s).to eq(@ws.description)
    end
  end

  context "in a IUF competition" do
    let!(:ec) { FactoryBot.create(:event_configuration, usa: false) }
    let!(:ws_16_inch) { FactoryBot.create(:wheel_size_16) }
    let!(:ws_20_inch) { FactoryBot.create(:wheel_size_20) }
    let!(:ws_24_inch) { FactoryBot.create(:wheel_size_24) }

    it "doesn't list 16 inch wheel size" do
      expect(described_class.available_sizes.count).to eq(2)
    end
  end
end

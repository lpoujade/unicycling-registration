require 'spec_helper'

describe Exporters::OrganizationMembershipsExporter do
  before do
    FactoryBot.create_list(:competitor, 5)
  end

  it "outputs some rows" do
    exporter = described_class.new(Registrant.all)
    expect(exporter.headers).to include("Id")
    expect(exporter.headers).to include("Organization Membership#")
    expect(exporter.rows.count).to eq(5)
  end
end

require 'csv'
class Compete::WavesController < ApplicationController
  before_action :authenticate_user!

  load_resource :competition
  authorize_resource :competition, parent: false

  before_action :set_parent_breadcrumbs

  respond_to :html

  # GET /competitions/1/waves
  def show
    add_breadcrumb "Current Heats"
    @competitors = @competition.competitors
    respond_to do |format|
      format.xls {
        s = Spreadsheet::Workbook.new

        sheet = s.create_worksheet
        sheet[0, 0] = "ID"
        sheet[0, 1] = "Heat"
        sheet[0, 2] = "Name"
        @competitors.each.with_index(1) do |comp, row_number|
          sheet[row_number, 0] = comp.lowest_member_bib_number
          sheet[row_number, 1] = comp.heat
          sheet[row_number, 2] = comp.detailed_name
        end

        report = StringIO.new
        s.write report
        send_data report.string, :filename => "#{@competition.slug}-waves-draft-#{Date.today}.xls"
      }
      format.html {} # normal
    end
  end

  # PUT /competitions/1/waves
  def update
    if params[:file].respond_to?(:tempfile)
      file = params[:file].tempfile
    else
      file = params[:file]
    end

    begin
      Competitor.transaction do
        File.open(file, 'r:ISO-8859-1') do |f|
          f.each_with_index do |line, index|
            next if index == 0
            row = CSV.parse_line (line)
            bib_number = row[0]
            heat = row[1]
            # skip blank lines
            next if bib_number.nil? && heat.nil?
            competitor = @competition.competitors.where(lowest_member_bib_number: bib_number).first
            raise "Unable to find competitor #{bib_number}" if competitor.nil?
            competitor.update_attribute(:heat, heat)
          end
        end
      end
      flash[:notice] = "Waves Configured"
    rescue Exception => ex
      flash[:alert] = "Error processing file #{ex}"
    end

    redirect_to competition_waves_path(@competition)
  end

  private

  def set_parent_breadcrumbs
    add_breadcrumb "#{@competition}", competition_path(@competition)
  end
end

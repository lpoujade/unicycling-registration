class Admin::RegistrantsController < Admin::BaseController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @registrants = Registrant.all
  end

  def bag_labels
    @registrants = Registrant.all

    names = []
    @registrants.each do |reg|
      names << "<b>##{reg.id}</b> #{reg.name} \n #{reg.country}"
    end

    labels = Prawn::Labels.render(names, :type => "Avery5160") do |pdf, name|
      pdf.text name, :align => :center, :size => 10, :inline_format => true
    end

    send_data labels, :filename => "names.pdf", :type => "application/pdf"
  end
end

class Printing::EventsController < ApplicationController
  before_filter :authenticate_user!
  skip_authorization_check

  before_filter :load_event

  def load_event
    @event = Event.find(params[:id])
  end

  def results
    @competitions = @event.competitions

    @no_page_breaks = true #unless params[:no_page_breaks].nil?

    respond_to do |format|
      format.html 
      format.pdf { render_common_pdf("results", "Portrait") }
    end
  end
end


class ConventionSetup::PagesController < ConventionSetup::BaseConventionSetupController
  before_action :load_page, except: %i[index new create]
  before_action :authorize_setup

  before_action :set_breadcrumbs

  respond_to :html

  # GET /convention_setup/pages
  def index
    load_pages

    respond_with([:convention_setup, @pages])
  end

  # GET /pages/new
  def new
    @page = Page.new
  end

  # POST /pages
  def create
    @page = Page.new(page_params)
    if @page.save
      flash[:notice] = 'Page was successfully created.'
      redirect_to convention_setup_page_path(@page)
    else
      render :new
    end
  end

  # GET /pages/1/edit
  def edit; end

  # PUT /event_choices/1
  def update
    if @page.update(page_params)
      flash[:notice] = 'Page was successfully updated.'
    end
    respond_with(@page, location: [:convention_setup, @page], action: "edit")
  end

  # DELETE /event_choices/1
  def destroy
    @page.destroy

    respond_with(@page, location: convention_setup_pages_path)
  end

  private

  def authorize_setup
    authorize @config, :setup_convention?
  end

  def set_breadcrumbs
    add_breadcrumb "Pages", convention_setup_pages_path
    add_breadcrumb "#{@page} Page", convention_setup_page_path(@page) if @page
  end

  def load_page
    @page = Page.find(params[:id])
  end

  def load_pages
    @pages = Page.all
  end

  def page_params
    params.require(:page).permit(:slug, :title, :visible, :body, :position, :parent_page_id,
                                 translations_attributes: %i[id locale title body])
  end
end

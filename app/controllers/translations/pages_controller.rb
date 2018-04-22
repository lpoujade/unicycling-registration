class Translations::PagesController < Admin::TranslationsController
  before_action :load_page, except: :index

  def index
    @pages = Page.all
  end

  # GET /translations/pages/1/edit
  def edit; end

  # PUT /translations/pages/1
  def update
    if @page.update(page_params)
      flash[:notice] = 'Page was successfully updated.'
      redirect_to action: :index
    else
      render :edit
    end
  end

  private

  def load_page
    @page = Page.find(params[:id])
  end

  def page_params
    params.require(:page).permit(translations_attributes: %i[id locale title body])
  end
end

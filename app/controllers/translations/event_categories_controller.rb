class Translations::EventCategoriesController < Admin::TranslationsController
  before_action :load_event_category, except: :index

  def index
    @event_categories = EventCategory.all
  end

  # GET /translations/event_categories/1/edit
  def edit; end

  # PUT /translations/event_categories/1
  def update
    if @event_category.update(event_category_params)
      flash[:notice] = 'Event Category was successfully updated.'
      redirect_to action: :index
    else
      render :edit
    end
  end

  private

  def load_event_category
    @event_category = EventCategory.find(params[:id])
  end

  def event_category_params
    params.require(:event_category).permit(translations_attributes: %i[id locale name])
  end
end

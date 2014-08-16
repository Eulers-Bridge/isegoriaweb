class EventsController < ApplicationController
  #Set the default layout for this controller, the views from this controller are available when the user is looged in
  layout 'application'

  def index
    @events_list = Event.all
  end

  def new
	@event = Event.new #Set a new event object to be filled by the user form
  end

  def edit
	@event = Event.find(params[:id])
  end

  def create
    @event = Event.new(event_params)
    if @event.save
  	  flash[:success] = t(:event_creation_success_flash, event: @event.name)
      redirect_to events_path
    else
      flash[:danger] = t(:event_creation_error_flash)
   	  @article = Article.new
   	  redirect_to new_event_path
    end
  end

  def update
	@event = Event.find(params[:id])
	if @event.update_attributes(event_params)
	  flash[:success] = t(:event_modification_success_flash, event: @event.name)
	  redirect_to events_path
	else
      flash[:danger] = t(:event_modification_error_flash)
      redirect_to edit_event_path
	end
  end

  def destroy
  end

  private
  def event_params
    params.require(:event).permit(:name, :date, :location, :description, :picture, :volunteers)
  end
end

class EventsController < ApplicationController
  #Set the default layout for this controller, the views from this controller are available when the user is looged in
  layout 'application'
  @@images_directory = "UniversityOfMelbourne/Events"

  def index
    @page_aux = params[:page]
    @page = @page_aux =~ /\A\d+\z/ ? @page_aux.to_i : 0 
    resp = Event.all(session[:user],@page)
    if resp[0]
      @events_list = resp[1]
      @total_pages = resp[3].to_i
      @previous_page = @page > 0 ? @page-1 : -1
      @next_page = @page+1 < @total_pages ? @page+1 : -1
    elsif validate_authorized_access(resp[1])
      flash[:danger] = t(:event_list_error_flash)
      redirect_to error_general_error_path
    end
  end

  def new
	  @event = Event.new #Set a new event object to be filled by the user form
  end

  def edit
	  resp = Event.find(params[:id],session[:user])
    if resp[0]
      @event = resp[1]
    elsif validate_authorized_access(resp[1])
      flash[:danger] = t(:event_get_error_flash)
    redirect_to events_path
    end
  end

  def create
    @event = Event.new(event_params)
    resp = @event.save(session[:user])
    if resp[0]
      @event = resp[1]
      if !resp[2]
        flash[:warning] = t(:event_photo_creation_error_flash)
      end
  	  flash[:success] = t(:event_creation_success_flash, event: @event.name)
      redirect_to events_path
    elsif validate_authorized_access(resp[1])
      if(resp[1].kind_of?(Array))
        flash[:warning] = Util.format_validation_errors(resp[1])
      end
      flash[:danger] = t(:event_creation_error_flash)
   	  @event = Event.new
   	  redirect_to new_event_path
    end
  end

  def update
	  resp = Event.find(params[:id],session[:user])
    if resp[0]
      @event = resp[1]
    elsif validate_authorized_access(resp[1])
      flash[:danger] = t(:event_get_error_flash)
      redirect_to events_path
    end
    resp2 = @event.update_attributes(event_params,session[:user])
    if resp2[0]
      flash[:success] = t(:event_modification_success_flash, event: @event.name)
      redirect_to events_path
    elsif validate_authorized_access(resp[1])
      if(resp[1].kind_of?(Array))
        flash[:warning] = Util.format_validation_errors(resp[1])
      end
      flash[:danger] = t(:event_modification_error_flash)
      redirect_to edit_event_path
    end
  end

  def upload_picture
    resp = Event.find(params[:id],session[:user])
    if resp[0]
    @event = resp[1]
    elsif validate_authorized_access(resp[1])
      flash[:danger] = t(:event_get_error_flash)
    redirect_to :back
    end
    resp2 = @event.upload_picture(event_params,session[:user])
    if resp2[0]
      flash[:success] = t(:picture_uploading_success_flash, event: @event.name)
      redirect_to :back
    elsif validate_authorized_access(resp[1])
      if(resp[1].kind_of?(Array))
          flash[:warning] = Util.format_validation_errors(resp[1])
        end
        flash[:danger] = t(:picture_uploading_error_flash)
        redirect_to :back
    end
  end

  def delete_picture
    resp = Photo.find(params[:id],session[:user])
      if resp[0]
      photo = resp[1]
      elsif validate_authorized_access(resp[1])
        flash[:danger] = t(:photo_get_error_flash)
        redirect_to :back
      end
      resp2 = photo.delete(session[:user])
      if resp2[0]
        flash[:success] = t(:picture_deletion_success_flash, photo: photo.title)
      elsif validate_authorized_access(resp[1])
        flash[:danger] = t(:picture_deletion_error_flash)
      end
      redirect_to :back
  end

  def destroy
    resp = Event.find(params[:id],session[:user])
    if resp[0]
      @event = resp[1]
    elsif validate_authorized_access(resp[1])
      flash[:danger] = t(:event_deletion_error_flash)
      redirect_to events_path
    end
    resp2 = @event.delete(session[:user])
    if resp2[0]
      flash[:success] = t(:event_deletion_success_flash, article: @event.name)
    elsif validate_authorized_access(resp[1])
      flash[:danger] = t(:event_deletion_error_flash)
    end
      redirect_to events_path
  end

  private
  def event_params
    params.require(:event).permit(:name, :start_date, :start_time, :end_date, :end_time, :location, :description, :picture, :volunteers, :organizer, :organizer_email, :previous_picture)
  end
end

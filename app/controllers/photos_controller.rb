class PhotosController < ApplicationController
  #Set the default layout for this controller, the views from this controller are available when the user is looged in
  layout 'application'

  def index
    @page_aux = params[:page]
    @page = @page_aux =~ /\A\d+\z/ ? @page_aux.to_i : 0 
    resp = Photo.all(session[:user],@page)
    if resp[0]
      @photos_list = resp[1]
      @total_pages = resp[3].to_i
      @previous_page = @page > 0 ? @page-1 : -1
      @next_page = @page+1 < @total_pages ? @page+1 : -1
    elsif validate_authorized_access(resp[1])
      flash[:danger] = t(:photo_list_error_flash)
      redirect_to error_general_error_path
    end 
  end

  def new
    @photo = Photo.new #Set a new article object to be filled by the user form
  end

  def create
    @photo = Photo.new(photo_params)
    @photo.owner_id = session[:user]['id']
    resp = @photo.save(session[:user],nil)
    if resp[0]
      flash[:success] = t(:photo_creation_success_flash, article: @photo.title)
      redirect_to photos_path
    elsif validate_authorized_access(resp[1])
        if(resp[1].kind_of?(Array))
          flash[:warning] = Util.format_validation_errors(resp[1])
        end
        flash[:danger] = t(:photo_creation_error_flash)
        @photo = Photo.new
        redirect_to new_photo_path
    end
  end

  def edit
    resp = Photo.find(params[:id],session[:user])
    if resp[0]
    @photo = resp[1]
    elsif validate_authorized_access(resp[1])
      flash[:danger] = t(:photo_get_error_flash)
    redirect_to photo_path
    end
  end

  def update
    resp = Photo.find(params[:id],session[:user])
    if resp[0]
    @photo = resp[1]
    elsif validate_authorized_access(resp[1])
      flash[:danger] = t(:photo_get_error_flash)
    redirect_to photos_path
    end
    resp2 = @photo.update_attributes(photo_params,session[:user],nil)
    if resp2[0]
      flash[:success] = t(:photo_modification_success_flash, photo: @photo.title)
      redirect_to photos_path
    elsif validate_authorized_access(resp[1])
      if(resp[1].kind_of?(Array))
        flash[:warning] = Util.format_validation_errors(resp[1])
      end
        flash[:danger] = t(:photo_modification_error_flash)
        redirect_to edit_photo_path
    end
  end

  def destroy
    resp = Photo.find(params[:id],session[:user])
    if resp[0]
    @photo = resp[1]
    elsif validate_authorized_access(resp[1])
      flash[:danger] = t(:photo_get_error_flash)
    redirect_to photos_path
    end
    resp2 = @photo.delete(session[:user])
    if resp2[0]
      flash[:success] = t(:photo_deletion_success_flash, photo: @photo.title)
    elsif validate_authorized_access(resp[1])
        flash[:danger] = t(:photo_deletion_error_flash)
      end
      redirect_to photos_path
  end

  private
    def photo_params
      params.require(:photo).permit(:title, :description, :file, :owner_id, :date, :previous_picture)
    end
end

class PhotosController < ApplicationController
  #Set the default layout for this controller, the views from this controller are available when the user is looged in
  layout 'application'

  def index
  	@photo = Photo.new #Set a new article object to be filled by the user form
    @photos_list = Photo.all
  end

  def create
	@photo = Photo.new(photo_params)
	if @photo.save
	  flash[:success] = t(:photo_creation_success_flash, photo: @photo.title)
	  redirect_to photos_path
	else
      flash[:danger] = t(:photo_creation_error_flash)
      @photo = Photo.new
      redirect_to photos_path
    end
  end

  def destroy
  end

  private
    def photo_params
      params.require(:photo).permit(:title, :path)
    end
end

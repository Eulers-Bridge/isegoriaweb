class PhotoAlbumsController < ApplicationController
	def index
		@page_aux = params[:page]
		@page = @page_aux =~ /\A\d+\z/ ? @page_aux.to_i : 0 
		resp = PhotoAlbum.all(session[:user],@page)
		if resp[0]
		  @photo_albums_list = resp[1]
		  @total_pages = resp[3].to_i
		  @previous_page = @page > 0 ? @page-1 : -1
		  @next_page = @page+1 < @total_pages ? @page+1 : -1
		elsif validate_authorized_access(resp[1])
			flash[:danger] = t(:photo_album_list_error_flash)
			redirect_to error_general_error_path
		end	
	end
end

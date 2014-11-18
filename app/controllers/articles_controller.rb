class ArticlesController < ApplicationController

	#Set the default layout for this controller, the views from this controller are available when the user is looged in
  	layout 'application'
  	#check_session

	def index
		@page_aux = params[:page]
		@page = @page_aux =~ /\A\d+\z/ ? @page_aux.to_i : 0 
		resp = Article.all(session[:user],@page)
		if resp[0]
		  @articles_list = resp[1]
		  @total_pages = resp[3].to_i
		  @previous_page = @page > 0 ? @page-1 : -1
		  @next_page = @page+1 < @total_pages ? @page+1 : -1
		elsif validate_authorized_access(resp[1])
			flash[:danger] = t(:article_list_error_flash)
			redirect_to error_general_error_path
		end	
	end

	def new
		@article = Article.new #Set a new article object to be filled by the user form
	end

	def edit
	  resp = Article.find(params[:id],session[:user])
	  if resp[0]
		@article = resp[1]
	  elsif validate_authorized_access(resp[1])
	    flash[:danger] = t(:article_get_error_flash)
		redirect_to articles_path
	  end
	end

	def create
	  @article = Article.new(article_params)
	  @article.creator_email = session[:user]['email']
	  resp = @article.save(session[:user])
	  if resp[0]
	  	flash[:success] = t(:article_creation_success_flash, article: @article.title)
	    redirect_to articles_path
	  elsif validate_authorized_access(resp[1])
        flash[:danger] = t(:article_creation_error_flash)
      	@article = Article.new
      	redirect_to new_article_path
	  end
	end

	def update
	  resp = Article.find(params[:id],session[:user])
	  if resp[0]
		@article = resp[1]
	  elsif validate_authorized_access(resp[1])
	    flash[:danger] = t(:article_get_error_flash)
		redirect_to articles_path
	  end
	  resp2 = @article.update_attributes(article_params,session[:user])
	  if resp2[0]
	  	flash[:success] = t(:article_modification_success_flash, article: @article.title)
	    redirect_to articles_path
	  elsif validate_authorized_access(resp[1])
        flash[:danger] = t(:article_modification_error_flash)
      	redirect_to edit_article_path
	  end
	end

	def destroy
	  resp = Article.find(params[:id],session[:user])
	  if resp[0]
		@article = resp[1]
	  elsif validate_authorized_access(resp[1])
	    flash[:danger] = t(:article_deletion_error_flash)
		redirect_to articles_path
	  end
	  resp2 = @article.delete(session[:user])
	  if resp2[0]
	    flash[:success] = t(:article_deletion_success_flash, article: @article.title)
	  elsif validate_authorized_access(resp[1])
        flash[:danger] = t(:article_deletion_error_flash)
      end
      redirect_to articles_path
	end

	def like
	  resp = Article.like(params[:id],session[:user])
	  if resp
		flash[:success] = t(:article_like_success_flash)
	  elsif validate_authorized_access(resp[1])
	    flash[:danger] = t(:article_like_error_flash)
	  end
	  redirect_to articles_path
	end

	def unlike
      resp = Article.unlike(params[:id],session[:user])
	  if resp
		flash[:success] = t(:article_unlike_success_flash)
	  elsif validate_authorized_access(resp[1])
	    flash[:danger] = t(:article_unlike_error_flash)
	  end
	  redirect_to articles_path
	end

	private
    def article_params
      params.require(:article).permit(:title, :content, :picture, :creator_email, :date, :previous_picture)
    end
end

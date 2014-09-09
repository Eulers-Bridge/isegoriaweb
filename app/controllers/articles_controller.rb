class ArticlesController < ApplicationController

	#Set the default layout for this controller, the views from this controller are available when the user is looged in
  	layout 'application'

	def index
		resp = Article.all
		if resp[0]
			@articles_list = resp[1]
		else
			flash[:danger] = t(:article_list_error_flash)
			redirect_to users_path
		end	
	end

	def new
		@article = Article.new #Set a new article object to be filled by the user form
	end

	def edit
	  resp = Article.find(params[:id])
	  if resp[0]
		@article = resp[1]
	  else
	    flash[:danger] = t(:article_get_error_flash)
		redirect_to users_path
	  end
	end

	def create
	  @article = Article.new(article_params)
	  resp = @article.save
	  if resp[0]
	  	flash[:success] = t(:article_creation_success_flash, article: @article.title)
	    redirect_to articles_path
	  else
        flash[:danger] = t(:article_creation_error_flash)
      	@article = Article.new
      	redirect_to new_article_path
	  end
	end

	def update
	  resp = Article.find(params[:id])
	  if resp[0]
		@article = resp[1]
	  else
	    flash[:danger] = t(:article_get_error_flash)
		redirect_to users_path
	  end
	  resp2 = @article.update_attributes(article_params)
	  if resp2[0]
	  	flash[:success] = t(:article_modification_success_flash, article: @article.title)
	    redirect_to articles_path
	  else
        flash[:danger] = t(:article_modification_error_flash)
      	redirect_to edit_article_path
	  end
	end

	def destroy
	end

	private
    def article_params
      params.require(:article).permit(:title, :content, :picture, :creator_email)
    end
end

class ArticlesController < ApplicationController

	#Set the default layout for this controller, the views from this controller are available when the user is looged in
  	layout 'application'

	def index
		@articles_list = Article.all
	end

	def new
		@article = Article.new #Set a new article object to be filled by the user form
	end

	def edit
		@article = Article.find(params[:id])
	end

	def create
	  @article = Article.new(article_params)
	  if @article.save
	  	flash[:success] = t(:article_creation_success_flash, article: @article.title)
	    redirect_to articles_path
	  else
        flash[:danger] = t(:article_creation_error_flash)
      	@article = Article.new
      	redirect_to new_article_path
	  end
	end

	def update
		@article = Article.find(params[:id])
	  if @article.update_attributes(article_params)
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
      params.require(:article).permit(:title, :content, :picture)
    end
end

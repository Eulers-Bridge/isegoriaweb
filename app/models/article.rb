class Article
  include ActiveModel::Model
  include ApplicationHelper

  attr_accessor :title, :content, :picture, :_links, :creator_email, :previous_picture
  attr_reader :id, :date, :student_year
  @@images_directory = "UniversityOfMelbourne/NewsArticles"

  validates :title, :presence => { :message => ApplicationHelper.validation_error(:title, :presence, nil) }
  validates :content, :presence => { :message => ApplicationHelper.validation_error(:content, :presence, nil) }
  validates :creator_email, :presence => { :message => ApplicationHelper.validation_error(:creator_email, :presence, nil) }
  validates :date, :presence => { :message => ApplicationHelper.validation_error(:date, :presence, nil) }
  validates :student_year, :presence => { :message => ApplicationHelper.validation_error(:student_year, :presence, nil) }

  def initialize (attributes = {})
    @id = attributes[:id]
    @title = attributes[:title]
    @picture = attributes[:picture]
    @previous_picture = attributes[:previous_picture]
    @content = attributes[:content]
    @_links = attributes[:_links]
    if !attributes[:creator_email].blank?
      @creator_email = attributes[:creator_email]
    else
      @creator_email = "test@eulersbridge.com"
    end
    if !attributes[:date].blank?
      @date = attributes[:date]#milliseconds passed since epoch Jan/1/1970
    else
      @date = Util.date_to_epoch(Time.now.strftime(I18n.t(:date_format_ruby)))
    end
    @student_year = Time.now.year.to_s
  end

  def save (user)
    if self.valid?
      Rails.logger.debug "The news article is valid!"
      @picture = self.picture
      if !@picture.blank?
        @file_s3_path = Util.upload_image(@@images_directory,@picture)
      else
        @file_s3_path = nil
      end
      article = {'title'=>self.title,
                'content'=>self.content,
                'picture'=>[@file_s3_path],
                'date'=> Util.date_to_epoch(self.date),
                'creatorEmail'=> self.creator_email,
                'institutionId'=> 26#change to user institution          
                }      
      reqUrl = "/api/newsArticle/"
      @rest_response = MwHttpRequest.http_post_request(reqUrl,article,user['email'],user['password'])
      Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
      if @rest_response.code == "200" || @rest_response.code == "201" || @rest_response.code == "202"
        return true, @rest_response
      else
        return false, "#{@rest_response.code} #{@rest_response.message}"
      end
    else
      Rails.logger.debug self.errors.full_messages
      return false, self.errors.full_messages
    end
  end

  def delete(user)
    if !self.picture.blank?
     Util.delete_image(self.picture[0])
    end
    reqUrl = "/api/newsArticle/#{self.id}"
    puts reqUrl
    @rest_response = MwHttpRequest.http_delete_request(reqUrl,user['email'],user['password'])
    Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
    if @rest_response.code == "200"
      return true, @rest_response
    else
      return false, "#{@rest_response.code} #{@rest_response.message}"
    end
  end

  def update_attributes(attributes = {},user)
    if self.valid?
      Rails.logger.debug "The news article is valid!"
      @picture = attributes[:picture]
      if !@picture.blank?
        @file_s3_path = Util.upload_image(@@images_directory,@picture)
        if !attributes[:previous_picture].blank?
          Util.delete_image(attributes[:previous_picture])
        end
      else
        @file_s3_path = self.picture
      end
      article = {'title'=>attributes[:title],
                'content'=>attributes[:content],
                'picture'=>[@file_s3_path],
                'date'=>Util.date_to_epoch(attributes[:date]),
                'creatorEmail'=>self.creator_email,
                'institutionId'=>26          
                }      
      reqUrl = "/api/newsArticle/#{self.id}"

      @rest_response = MwHttpRequest.http_put_request(reqUrl,article,user['email'],user['password'])
      Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
      if @rest_response.code == "200"
        return true, @rest_response
      else
        return false, "#{@rest_response.code} #{@rest_response.message}"
      end
    else
      Rails.logger.debug self.errors.full_messages
      return false, self.errors.full_messages
    end
  end

  def self.all(user, page)
    @institutionId = user['institutionId']
    @page = page != nil ? page : 0 
    reqUrl = "/api/newsArticles/#{@institutionId}?page=#{@page}&pageSize=10"
    @rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password'])
    Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
    if @rest_response.code == '200'
      @raw_articles_list = JSON.parse(@rest_response.body)
      @total_articles = @raw_articles_list['totalArticles']
      @total_pages = @raw_articles_list['totalPages']
      @articles_list = Array.new
      for article in @raw_articles_list['articles']
        if article["picture"].blank?
          @picture = Util.get_image_server+@@images_directory+'/generic_article.png'
        else
          @picture = article["picture"][0]
        end
        @articles_list << Article.new(
        id: article["articleId"], 
        title: article["title"], 
        content: article["content"], 
        picture: @picture, 
        creator_email: article["creatorEmail"], 
        date: article["date"],
        student_year: article["studentYear"],
        _links: article["_links"])
      end
      return true, @articles_list, @total_articles, @total_pages
    else
      return false, "#{@rest_response.code}", "#{@rest_response.message}"
    end
  end

  def self.find(id,user)
    reqUrl = "/api/newsArticle/#{id}"
    @rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password'])
    Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
    if @rest_response.code == '200'
      @raw_article = JSON.parse(@rest_response.body)
      if @raw_article["picture"].blank?
        @picture = [  ]
      else
        @picture = @raw_article["picture"]
      end
      @article = Article.new(
        id: @raw_article["articleId"], 
        title: @raw_article["title"], 
        content: @raw_article["content"], 
        picture: @picture, 
        creator_email:@raw_article["creatorEmail"], 
        date: Util.epoch_to_date(@raw_article["date"]),
        student_year: @raw_article["studentYear"])
      return true, @article
    else
      return false, "#{@rest_response.code} #{@rest_response.message}"
    end
  end

  def self.like(id,user)
    reqUrl = "/api/newsArticle/#{id}/likedBy/"+user['email']+"/"
    @rest_response = MwHttpRequest.http_put_request_simple(reqUrl,user['email'],user['password'])
    Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
    if @rest_response.code == '200'
      puts @rest_response
      return true
    else
      return false, "#{@rest_response.code} #{@rest_response.message}"
    end
  end

  def self.unlike(id,user)
    reqUrl = "/api/newsArticle/#{id}/unlikedBy/"+user['email']+"/"
    @rest_response = MwHttpRequest.http_put_request_simple(reqUrl,user['email'],user['password'])
    Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
    if @rest_response.code == '200'
      puts @rest_response
      return true
    else
      return false, "#{@rest_response.code} #{@rest_response.message}"
    end
  end
end
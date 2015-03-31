class Article
  include ActiveModel::Model
  include ApplicationHelper
  require 'photo'

  attr_accessor :title, :content, :picture, :_links, :creator_email, :previous_picture
  attr_reader :id, :date, :student_year
  @@images_directory = "UniversityOfMelbourne/NewsArticles"

  validates :title, :presence => { :message => ApplicationHelper.validation_error(:title, :presence, nil) }
  validates :content, :presence => { :message => ApplicationHelper.validation_error(:content, :presence, nil) }
  validates :creator_email, :presence => { :message => ApplicationHelper.validation_error(:creator_email, :presence, nil) }
  validates :date, :presence => { :message => ApplicationHelper.validation_error(:date, :presence, nil) }
  
=begin
--------------------------------------------------------------------------------------------------------------------
  Article object constructor
--------------------------------------------------------------------------------------------------------------------
=end
  def initialize (attributes = {})
    @id = attributes[:id]
    @title = attributes[:title]
    @picture = attributes[:picture]
    @previous_picture = attributes[:previous_picture]
    @content = attributes[:content]
    @_links = attributes[:_links]
    @creator_email = attributes[:creator_email]
    if !attributes[:date].blank?
      @date = attributes[:date]#milliseconds passed since epoch Jan/1/1970
    else
      @date = Util.date_to_epoch(Time.now.strftime(I18n.t(:date_format_ruby)))
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to create a new Article
  Param 1: logged user object
  Return if successful: 1.execution result(true), 
                        2.created election object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def save (user)
    Rails.logger.debug "Call to article.save"
    if self.valid? #Validate if the Article object is valid
      Rails.logger.debug "The news article is valid!"
      picture = self.picture
      if !picture.blank?
        file_s3_path = Util.upload_image(@@images_directory,picture)
      else
        file_s3_path = nil
      end
      #Create a raw article object
      article = {'title'=>self.title,
                'content'=>self.content,
                'picture'=>[file_s3_path],
                'date'=> Util.date_to_epoch(self.date),
                'creatorEmail'=> self.creator_email,
                'institutionId'=> user['institutionId']          
                }      
      reqUrl = "/api/newsArticle/" #Set the request url
      rest_response = MwHttpRequest.http_post_request(reqUrl,article,user['email'],user['password']) #Make the POST call to the server with the required parameters
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200" || rest_response.code == "201" || rest_response.code == "202" #Validate if the response from the server is satisfactory
        article = Article.rest_to_article(rest_response.body) #Turn the response object to an Article object
        #Create Photo node for new news article
        if article.picture.any?
          Rails.logger.debug 'Create Photo node for new news article: ' + article.id.to_s
          photo = Photo.new(title:article.title,description:article.title, file:article.picture[0], owner_id:article.id, date:article.date, previous_picture:"")
          resp = photo.save_photo_node(user)
          if !resp[0]
            return true, article, false
          end
        end
        return true, article, true
      else
        return false, "#{rest_response.code} #{rest_response.message}",false
      end
    else
      Rails.logger.debug self.errors.full_messages
      return false, self.errors.full_messages
    end
  end

  def delete(user)
    Rails.logger.debug "Call to article.delete"
    if !self.picture.blank?
     Util.delete_image(self.picture[0])
    end
    reqUrl = "/api/newsArticle/#{self.id}"
    rest_response = MwHttpRequest.http_delete_request(reqUrl,user['email'],user['password'])
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == "200"
      return true, rest_response
    else
      return false, "#{rest_response.code} #{rest_response.message}"
    end
  end

  def update_attributes(attributes = {},user)
    Rails.logger.debug "Call to article.update_attributes"
    if self.valid?
      Rails.logger.debug "The news article is valid!"
      picture = attributes[:picture]
      if !picture.blank?
        file_s3_path = Util.upload_image(@@images_directory,picture)
        if !attributes[:previous_picture].blank?
          Util.delete_image(attributes[:previous_picture])
        end
      else
        file_s3_path = self.picture[0]
      end
      article = {'title'=>attributes[:title],
                'content'=>attributes[:content],
                'photos'=>[file_s3_path],
                'date'=>Util.date_to_epoch(attributes[:date]),
                'creatorEmail'=>self.creator_email,
                'institutionId'=>user['institutionId']          
                }      
      reqUrl = "/api/newsArticle/#{self.id}"
      rest_response = MwHttpRequest.http_put_request(reqUrl,article,user['email'],user['password'])
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200"
        article = Article.rest_to_article(rest_response.body)
        return true, article
      else
        return false, "#{rest_response.code} #{rest_response.message}"
      end
    else
      Rails.logger.debug self.errors.full_messages
      return false, self.errors.full_messages
    end
  end

  def self.all(user, page)
    Rails.logger.debug "Call to article.all"
    institutionId = user['institutionId']
    page = page != nil ? page : 0 
    reqUrl = "/api/newsArticles/#{institutionId}?page=#{page}&pageSize=10"
    rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password'])
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == '200'
      raw_articles_list = JSON.parse(rest_response.body)
      total_articles = raw_articles_list['totalArticles']
      total_pages = raw_articles_list['totalPages']
      articles_list = Array.new
      for raw_article in raw_articles_list['articles']
        article = Article.rest_to_article(raw_article.to_json)
        articles_list << article
      end
      return true, articles_list, total_articles, total_pages
    else
      return false, "#{rest_response.code}", "#{rest_response.message}"
    end
  end

  def self.find(id,user)
    Rails.logger.debug "Call to article.find"
    reqUrl = "/api/newsArticle/#{id}"
    rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password'])
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == '200'
      article = Article.rest_to_article(rest_response.body)
      return true, article
    else
      return false, "#{rest_response.code} #{rest_response.message}"
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to transform the raw object received from the middleware to an Article object
  Param 1: Raw object
  Return 1: Transformed Article object
--------------------------------------------------------------------------------------------------------------------
=end
private
  def self.rest_to_article(rest_body)
    raw_article = JSON.parse(rest_body) #Turn the object to JSON to be able to manipulate it
      if raw_article["photos"].blank?
        picture = []
      else
        raw_pictures = raw_article["photos"]
        picture=JSON.parse(raw_pictures.to_json)
      end
      article = Article.new(
        id: raw_article["articleId"], 
        title: raw_article["title"], 
        content: raw_article["content"], 
        picture: picture, 
        creator_email:raw_article["creatorEmail"], 
        date: Util.epoch_to_date(raw_article["date"]),#Turn the epoch time to a string date, format defined by the locale parameter
        _links: raw_article["_links"])  
      return article #Return the transformed object  
  end
end
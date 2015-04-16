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
                        3.photo creation status
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def save (user)
    Rails.logger.debug "Call to article.save"
    if self.valid? #Validate if the Article object is valid
      Rails.logger.debug "The news article is valid!"
      picture = self.picture #Retrieve the picture object
      #Create a raw article object
      article = {'title'=>self.title,
                'content'=>self.content,
                'date'=> Util.date_to_epoch(self.date),
                'creatorEmail'=> self.creator_email,
                'institutionId'=> user['institutionId']          
                }      
      reqUrl = "/api/newsArticle/" #Set the request url
      rest_response = MwHttpRequest.http_post_request(reqUrl,article,user['email'],user['password']) #Make the POST call to the server with the required parameters
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200" || rest_response.code == "201" || rest_response.code == "202" #Validate if the response from the server is satisfactory
        article = Article.rest_to_article(rest_response.body) #Turn the response object to an Article object
        if !picture.blank?#Validate if the user supplied a picture
          #Create Photo node for new news article
          #Currently the wep app supports only one picture creation
          Rails.logger.debug 'Create Photo node for new news article: ' + article.id.to_s
          photo = Photo.new(
            title:article.title,
            description:article.title, 
            file:picture, 
            owner_id:article.id, 
            date:article.date)
          resp = photo.save(user,@@images_directory+"/"+article.id.to_s)#A new folder will be created for the article in the images server
          if !resp[0]
            return true, article, false #Return the notification that there was an error creating the picture node
          end
        end
        return true, article, true #Return success
      else
        return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
      end
    else
      Rails.logger.debug self.errors.full_messages
      return false, self.errors.full_messages #Return invalid object error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to delete an Article
  Param 1: logged user object
  Return if successful: 1.execution result(true), 
                        2.server response
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def delete(user)
    Rails.logger.debug "Call to article.delete"
    photo_deletion = true #Initialize the photo deletion flag to true
    if self.picture.any? #Check if there are any photos related to the article
      for picture_obj in self.picture #Delete all photo nodes owned by the article
        photo = Photo.new(id:picture_obj["nodeId"])#Create the node object to delete
        resp_photo = photo.delete(user)#Delete the photo node
        if !resp_photo[0] #An error has ocurred when deleting photos
          photo_deletion = false #Set the photo deletion flag to false
        end
      end
      Util.delete_image_folder(@@images_directory,self.id.to_s)#Delete the entire image folder related to the article
    end
   
    if !photo_deletion #Validate if there were error when deleting photos
      return false, resp[1], resp[2] #Return error
    end

    reqUrl = "/api/newsArticle/#{self.id}" #Set the request url
    rest_response = MwHttpRequest.http_delete_request(reqUrl,user['email'],user['password']) #Make the DELETE request to the server with the required parameters
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == "200" #Validate if the response from the server is 200, which means OK
      return true, rest_response #Return success
    else
      return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to update an Article
  Param 1: attributes to update
  Param 2: logged user object
  Return if successful: 1.execution result(true), 
                        2.updated article object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def update_attributes(attributes = {},user)
    Rails.logger.debug "Call to article.update_attributes"
    if self.valid? #Validate if the Article object is valid
      Rails.logger.debug "The news article is valid!"
      
      #Create a raw Article object
      article = {'title'=>attributes[:title],
                'content'=>attributes[:content],
                'date'=>Util.date_to_epoch(attributes[:date]),
                'creatorEmail'=>self.creator_email,
                'institutionId'=>user['institutionId']          
                }
      reqUrl = "/api/newsArticle/#{self.id}" #Set the request url
      rest_response = MwHttpRequest.http_put_request(reqUrl,article,user['email'],user['password']) #Make the PUT request to the server with the required parameters
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200" #Validate if the response from the server is 200, which means OK
        article = Article.rest_to_article(rest_response.body)
        return true, article #Return success
      else
        return false, "#{rest_response.code}", "#{rest_response.message}"#Return error
      end
    else
      Rails.logger.debug self.errors.full_messages
      return false, self.errors.full_messages #Return invalid object error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to upload a picture for an Article
  Param 1: attributes to update
  Param 2: logged user object
  Return if successful: 1.execution result(true), 
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def upload_picture(attributes = {}, user)
    Rails.logger.debug "Call to article.upload_picture"
    picture = attributes[:picture]#Get the picture object
    if !picture.blank?#Validate if the user supplied a picture
      #Create Photo node for new news article
      #Currently the wep app supports only one picture creation
      if attributes[:previous_picture].blank? #If no previous picture exists, then a new photo node is created
        Rails.logger.debug 'Create Photo node for news article: ' + self.id.to_s
        photo = Photo.new(
          title:self.title,
          description:self.title, 
          file:picture, 
          owner_id:self.id, 
          date:self.date)
        resp = photo.save(user,@@images_directory+"/"+self.id.to_s)
      else #Otherwise the picture node must be updated
        previous_picture = JSON.parse(attributes[:previous_picture])#Parse the previous picture object
        Rails.logger.debug 'Update Photo node for news article: ' + self.id.to_s
        photo = Photo.new(
          id:previous_picture['nodeId'],
          title:self.title,
          description:self.title, 
          file:picture, 
          owner_id:self.id, 
          date:self.date)
        resp = photo.update_photo_node(user,@@images_directory+"/"+self.id.to_s, previous_picture['url'])
      end
      if resp[0]
        return true, resp[1]#Return sucess
      else
        return false, resp[1], resp[2] #Return error
      end
    end
  end


=begin
--------------------------------------------------------------------------------------------------------------------
  Function to retrieve all the artilces by its institution id
  Param 1: logged user object
  Param 2: number of page requested(pagination)
  Return if successful: 1.execution result(true), 
                        2.array with the articles objects, 
                        3.total number of articles, 
                        4.total number of pages
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, 
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def self.all(user, page)
    Rails.logger.debug "Call to article.all"
    institutionId = user['institutionId'] #Retrieve the institution id from the logged user
    page = page != nil ? page : 0 #If not page is sent as parameter, set it to the first page
    reqUrl = "/api/newsArticles/#{institutionId}?page=#{page}&pageSize=10" #Build the request url

    rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password'])#Make the GET request to the Middleware server
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == '200' #Validate if the response from the server is 200, which means OK
      raw_articles_list = JSON.parse(rest_response.body) #Get the polls info from the response and normalize it to an array to handle it
      total_articles = raw_articles_list['totalElements'] #Retrieve the total articles number for pagination
      total_pages = raw_articles_list['totalPages'] #Retrieve the total number of pages for pagination
      articles_list = Array.new #Initialize an empty array for the articles
      for raw_article in raw_articles_list['foundObjects'] #For each article received from the server
        article = Article.rest_to_article(raw_article.to_json) #Turn an article to json format
        articles_list << article #Add it to the articles array
      end
      return true, articles_list, total_articles, total_pages #Return success
    else
      return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to retrieve an article by its id
  Param 1: article id
  Param 2: logged user object
  Return if successful: 1.execution result(true), 
                        2.Article object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def self.find(id,user)
    Rails.logger.debug "Call to article.find"
    reqUrl = "/api/newsArticle/#{id}" #Set the request url

    rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password']) #Make the GET request to the Middleware server
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == '200' #Validate if the response from the server is 200, which means OK
      article = Article.rest_to_article(rest_response.body) #Turn the response object to an Article object
      return true, article #Return success
    else
      return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
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
    raw_article = JSON.parse(rest_body) #Turn the object to an array to be able to manipulate it
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
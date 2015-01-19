class Photo
  include ActiveModel::Model

  attr_accessor :title, :description, :file, :date, :owner_id
  attr_reader :id
  @@images_directory = "UniversityOfMelbourne/Photos"

  validates :title, :presence => { :message => ApplicationHelper.validation_error(:title, :presence, nil) }
  validates :description, :presence => { :message => ApplicationHelper.validation_error(:description, :presence, nil) }
  validates :file, :presence => { :message => ApplicationHelper.validation_error(:file, :presence, nil) }
  validates :date, :presence => { :message => ApplicationHelper.validation_error(:date, :presence, nil) }
  
  def initialize (attributes = {})
    @id = attributes[:id]
    @title = attributes[:title]
    @description = attributes[:description]
    @file = attributes[:file]
    if !attributes[:date].blank?
      @date = attributes[:date]#milliseconds passed since epoch Jan/1/1970
    else
      @date = Util.date_to_epoch(Time.now.strftime(I18n.t(:date_format_ruby)))
    end
    if !attributes[:owner_id].blank?
      @owner_id = attributes[:owner_id]
    else
      @owner_id = "test@eulersbridge.com"
    end
  end

  def save (user) 
    if self.valid?
      Rails.logger.debug "The photo is valid!"
      @file = self.file
      if !@file.blank?
        @file_s3_path = Util.upload_image(@@images_directory,@file)
      else
        @file_s3_path = nil
      end
      photo = { 'title'=>self.title,
                'description'=>self.description,
                'url'=>@file_s3_path,
                'date'=> Util.date_to_epoch(self.date),
                'ownerId'=> self.owner_id         
                }
      reqUrl = "/api/photo/"
      @rest_response = MwHttpRequest.http_post_request(reqUrl,photo,user['email'],user['password'])
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
    if !self.file.blank?
     Util.delete_image(self.file)
    end
    reqUrl = "/api/photo/#{self.id}"
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
      Rails.logger.debug "The photo is valid!"
      @file = attributes[:file]
      if !@file.blank?
        @file_s3_path = Util.upload_image(@@images_directory,@file)
        if !attributes[:previous_file].blank?
          Util.delete_image(attributes[:previous_file])
        end
      else
        @file_s3_path = self.file
      end
      photo = { 'title'=>attributes[:title],
                'description'=>attributes[:description],
                'url'=>[@file_s3_path],
                'date'=> Util.date_to_epoch(attributes[:date]),
                'ownerId'=> self.owner_id         
                }
      reqUrl = "/api/photo/#{self.id}"

      @rest_response = MwHttpRequest.http_put_request(reqUrl,photp,user['email'],user['password'])
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

  def self.all(user, page, photoAlbum)
    @photoAlbum = photoAlbum
    @page = page != nil ? page : 0 
    reqUrl = "/api/photos/#{@photoAlbum}?page=#{@page}&pageSize=10"
    @rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password'])
    Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
    if @rest_response.code == '200'
      @raw_photos_list = JSON.parse(@rest_response.body)
      @total_photos = @raw_photos_list['totalPhotos']
      @total_pages = @raw_photos_list['totalPages']
      @photos_list = Array.new
      for photo in @raw_photos_list['photos']
        if photo["url"].blank?
          @file = Util.get_image_server+@@images_directory+'/no_image.png'
        else
          @file = photo["url"]
        end
        @photos_list << Photo.new(
        id: photo["nodeId"], 
        title: photo["title"], 
        description: photo["description"], 
        file: @file, 
        date: photo["date"],
        owner_id: photo["ownerId"],
        _links: photo["_links"])
      end
      return true, @photos_list, @total_photos, @total_pages
    else
      return false, "#{@rest_response.code}", "#{@rest_response.message}"
    end
  end

  def self.find(id,user)
    reqUrl = "/api/photo/#{id}"
    @rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password'])
    Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
    if @rest_response.code == '200'
      @raw_photo = JSON.parse(@rest_response.body)
      if @raw_photo["url"].blank?
        @file = nil
      else
        @file = @raw_photo["url"]
      end
      @photo = Photo.new(
        id: @raw_photo["nodeId"], 
        title: @raw_photo["title"], 
        description: @raw_photo["description"], 
        file: @file, 
        owner_id:@raw_photo["ownerId"], 
        date: Util.epoch_to_date(@raw_photo["date"]))
      return true, @photo
    else
      return false, "#{@rest_response.code} #{@rest_response.message}"
    end
  end

end
#Utility functions module to be accesible by the models
module Util
    #Function that capitalize every first letter on all words from a sentence
	def self.capitalize_as_title (string)
		string.split.map(&:capitalize).join(' ')
	end
	
	#Funcion that converts epoch milliseconds to a regular Time
	def self.epoch_to_date(epoch_milliseconds)
	  Time.at(epoch_milliseconds/1000).strftime(I18n.t(:date_format_ruby))
	end

  #Funcion that converts epoch milliseconds to a regular DateTime
  def self.epoch_to_datetime(epoch_milliseconds)
    Time.at(epoch_milliseconds/1000).strftime(I18n.t(:date_format_ruby)+" "+I18n.t(:time_format_ruby))
  end

  #Function that gets just the time part of an epoch date
  def self.epoch_get_time(epoch_milliseconds)
    Time.at(epoch_milliseconds/1000).strftime(I18n.t(:time_format_ruby))
  end

	#Fuction that converts a regular Date to epoch in milliseconds
	def self.date_to_epoch(date)
	 @date = Time.strptime(date, I18n.t(:date_format_ruby))
	 return @date.to_i*1000
	end

  #Function that converts a regular DateTime to epoch in milliseconds
  def self.datetime_to_epoch(datetime)
   @datetime = Time.strptime(datetime, I18n.t(:date_format_ruby)+" "+I18n.t(:time_format_ruby))
   return @datetime.to_i*1000
  end

  #Function that converst an Array to CSV(Comma Separated Values) String
  def self.array_to_csv(array)
    return array.map(&:inspect).join(', ')
  end

  #Function that converts an Array in string form to CSV(Comma Separated Values) String
  def self.arraystring_to_csv(arraystring)
    arraystring=arraystring.remove("[")
    arraystring=arraystring.remove("]")
    arraystring=arraystring.remove("\"")
    return arraystring
  end

  #Function to format validation error messages
  def self.format_validation_errors (errors_array)
    @message = ''
    errors_array.each do |message|
        @message = @message + ' * ' + message
    end
    return @message
  end

	#Function to upload an image
	def self.upload_image(directory,file)
      #Use the Amazon Web Server API to upload images
	  require 'aws-sdk'
	  #AWS.config(access_key_id: '...', secret_access_key: '...', region: 'us-west-2')
	  s3 = AWS::S3.new(:access_key_id => 'AKIAJ7CSCKRSDNOK24IQ',:secret_access_key => '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')
	  isegoria_bucket = s3.buckets['isegoria']# no request made
	  @path = ''
      
      #Loop until the random file name generated does not already exists
	  loop do
	  	#Generate a random file name
        @filename = (Time.now.strftime("%Y%m%d%H%M%S")+'_'+(0...24).map { ('a'..'z').to_a[rand(26)] }.join+File.extname(file.original_filename)).gsub(/\s+/, "")
        @path = File.join(directory, @filename)
      break if !isegoria_bucket.objects[@path].exists?
      end 

      #upload the file
      cache_time_seconds = 2419200 #Time for which the image will remain cached
      image_object = isegoria_bucket.objects.create(@path, file, :cache_control => "max-age=#{cache_time_seconds}")
      image_object.acl = :public_read
      return get_image_server+@path
	end

	#Function to delete an image
	def self.delete_image(path_to_file)

	  #Use the Amazon Web Server API to upload images
	  require 'aws-sdk'
	  #AWS.config(access_key_id: '...', secret_access_key: '...', region: 'us-west-2')
	  s3 = AWS::S3.new(:access_key_id => 'AKIAJ7CSCKRSDNOK24IQ',:secret_access_key => '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')
	  @file_key = path_to_file.gsub(get_image_server, "")
    isegoria_bucket = s3.buckets['isegoria']# no request made
      if isegoria_bucket.objects[@file_key].exists?
        isegoria_bucket.objects[@file_key].delete()
      else
      	Rails.logger.debug "AWS image file not found: "+path_to_file
      end
	  #File.delete(path_to_file) if File.exist?(path_to_file)
	end

  #Function to delete an images folder
  def self.delete_image_folder(path_to_folder,folder_id)

    #Use the Amazon Web Server API to upload images
    require 'aws-sdk'
    #AWS.config(access_key_id: '...', secret_access_key: '...', region: 'us-west-2')
    s3 = AWS::S3.new(:access_key_id => 'AKIAJ7CSCKRSDNOK24IQ',:secret_access_key => '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')
    isegoria_bucket = s3.buckets['isegoria']# no request made
    isegoria_bucket.objects.with_prefix(path_to_folder+"/"+folder_id).delete_all
  end

	#Function to retrieve the Institutions Catalog
	def self.get_institutions_catalog
	  reqUrl = '/api/general-info'

      @rest_response = MwHttpRequest.http_get_request_unauth(reqUrl)
      Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
      if @rest_response.code == '200'
      @raw_institutions_catalog = JSON.parse(@rest_response.body)
      #@articles_list = Array.new
      #for article in @raw_articles_list
      #  if article["picture"].blank?
      #    @picture = @@images_directory+'/generic_article.png'
      #  else
      #    @picture = article["picture"][0]
      #  end
      #  @articles_list << Article.new(
      #  id: article["articleId"], 
      #  title: article["title"], 
      #  content: article["content"], 
      #  picture: @picture, 
      #  creator_email: article["creatorEmail"], 
      #  date: article["date"],
      #  student_year: article["studentYear"],
      #  _links: article["_links"])
      #end
      return true, @raw_institutions_catalog
    else
      return false, "#{@rest_response.code}", "#{@rest_response.message}"
    end
	end

  #Function that retrieve the default server where images are being saved
  def self.get_image_server
    return "https://s3-ap-southeast-2.amazonaws.com/isegoria/"
  end
end
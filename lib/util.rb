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

	#Funcion that converts a regular Date to epoch in milliseconds
	def self.date_to_epoch(date)
	 @date = Time.strptime(date, I18n.t(:date_format_ruby))
	 @date.to_i*1000
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
      image_object = isegoria_bucket.objects.create(@path, file)
      image_object.acl = :public_read
      return @path
	end

	#Function to delete an image
	def self.delete_image(path_to_file)

	  #Use the Amazon Web Server API to upload images
	  require 'aws-sdk'
	  #AWS.config(access_key_id: '...', secret_access_key: '...', region: 'us-west-2')
	  s3 = AWS::S3.new(:access_key_id => 'AKIAJ7CSCKRSDNOK24IQ',:secret_access_key => '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')
	  isegoria_bucket = s3.buckets['isegoria']# no request made
      if isegoria_bucket.objects[path_to_file].exists?
        isegoria_bucket.objects[path_to_file].delete()
      else
      	Rails.logger.debug "AWS image file not found: "+path_to_file
      end
	  #File.delete(path_to_file) if File.exist?(path_to_file)
	end
end
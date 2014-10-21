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
	  # create the file path
      @filename = (Time.now.strftime("%Y%m%d%H%M%S")+'_'+(0...24).map { ('a'..'z').to_a[rand(26)] }.join+File.extname(file.original_filename)).gsub(/\s+/, "")
      path = File.join(directory, @filename)
      # write the file
      File.open(path, "wb") do |f| 
      	f.write(file.read)
      end
      return @filename
	end

	#Function to delete an image
	def self.delete_image(path_to_file)
		puts '++++++++++++++++'+path_to_file
		File.delete(path_to_file) if File.exist?(path_to_file)
	end
end
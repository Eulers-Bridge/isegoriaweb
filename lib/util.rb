#Utility functions module to be accesible by the models
module Util
#Function that capitalize every first letter on all words from a sentence
	def self.capitalize_as_title (string)
		string.split.map(&:capitalize).join(' ')
	end
	
	#Funcion that converts epoch milliseconds to a regular Time
	def self.epoch_to_date(epoch_milliseconds)
	  Time.at(epoch_milliseconds/1000).strftime("%d/%m/%Y")
	end

	#Funcion that converts a regular Date to epoch in milliseconds
	def self.date_to_epoch(date)
	 date.to_i*1000
	end
end
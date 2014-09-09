module ApplicationHelper
	
	#Function that capitalize every first letter on all words from a sentence
	def capitalize_as_title (string)
		string.split.map(&:capitalize).join(' ')
	end
	
	#Function that generates an Internationalizated validation error for any field
	def self.validation_error (field, error_type, parameter)
	  @message = I18n.t(field)
	  case error_type
		when :presence
			@message = @message + " " + I18n.t(:validation_error_presence)
		when :lenght
			@message = @message + " " + I18n.t(:validation_error_lenght, parameter: parameter)
		when :format
			@message = @message + " " + I18n.t(:validation_error_format, parameter: parameter)
		else
			@message = @message + " " + I18n.t(:validation_error_default)
	  end
	end
	
	#Funcion that converts epoch milliseconds to a regular Time
	def epoch_to_date(epoch_milliseconds)
	  Time.at(epoch_milliseconds/1000).strftime("%d/%m/%Y")
	end

	#Funcion that converts a regular Date to epoch in milliseconds
	def date_to_epoch(date)
	  date.strftime('%Q')
	end
end

module ApplicationHelper
	
	#Function that capitalize every first letter on all words from a sentence
	def capitalize_as_title (string)
		Util.capitalize_as_title(string)
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
	  Util.epoch_to_date(epoch_milliseconds)
	end

	#Funcion that converts epoch milliseconds to a regular DateTime
	def epoch_to_datetime(epoch_milliseconds)
	  Util.epoch_to_datetime(epoch_milliseconds)
	end

	#Function that gets just the time part of an epoch date
    def epoch_get_time(epoch_milliseconds)
      Util.epoch_get_time(epoch_milliseconds)
    end

	#Funcion that converts a regular Date to epoch in milliseconds
	def date_to_epoch(date)
	  Util.date_to_epoch(date)
	end

	#Funcion that converts a regular DateTime to epoch in milliseconds
    def datetime_to_epoch(datetime)
 	  Util.datetime_to_epoch(date)
    end

	#Function that retrieve the default server where images are being saved
	def get_image_server
		return Util.get_image_server
	end

	#Function to retrieve the translated country name by its code in the DB
	def get_country_name(country_code)
		case country_code
		  when 6241#USA
  		    return I18n.t(:iso_country_US)
		  when 6228#AUSTRALIA
  		    return I18n.t(:iso_country_AU)
		  when 6229#UK
  		  return I18n.t(:iso_country_UK)
		else
  		  return nil
		end
	end
end

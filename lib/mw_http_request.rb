module MwHttpRequest
  #Function that makes a POST request to the server without authentication
  def self.http_post_request_unauth (reqUrl, jsonObject)
    require 'json'
    require 'net/http'
    Rails.logger.debug 'Call to the http POST request module'
    uri = URI.parse('http://eulersbridge.com:8080/dbInterface' + reqUrl)

    http = Net::HTTP.new(uri.host, uri.port)
    #http.use_ssl = true
    #http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri)
    request.add_field('Content-Type', 'application/json')
    request.add_field('Accept', 'application/json')
    
    json_data = jsonObject.to_json
    Rails.logger.debug(request)
    Rails.logger.debug(json_data)
    http.request(request, json_data)
  end

  #Function that makes a POST request to the server with a json object as body
  def self.http_post_request (reqUrl, jsonObject, username, password)
    require 'json'
    require 'net/http'
    Rails.logger.debug 'Call to the http POST request module'
    uri = URI.parse('http://eulersbridge.com:8080/dbInterface' + reqUrl)

    http = Net::HTTP.new(uri.host, uri.port)
    #http.use_ssl = true
    #http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri)
    request.basic_auth username, password
    request.add_field('Content-Type', 'application/json')
    request.add_field('Accept', 'application/json')
    
    json_data = jsonObject.to_json
    Rails.logger.debug(request)
    Rails.logger.debug(json_data)
    http.request(request, json_data)
  end

  #Function that makes a GET request to the server
  def self.http_get_request (reqUrl, username, password)
    require 'net/http'
    Rails.logger.debug 'Call to the http GET request module'
    uri = URI.parse('http://eulersbridge.com:8080/dbInterface' + reqUrl)

    http = Net::HTTP.new(uri.host, uri.port)
    #http.use_ssl = true
    #http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    Rails.logger.debug 'Request: ' + uri.to_s
    request = Net::HTTP::Get.new(uri)
    request.basic_auth username, password
    request.add_field('Content-Type', 'application/json')
    request.add_field('Accept', 'application/json')

    Rails.logger.debug(request)
    http.request(request)
  end

  #Function that makes a GET request to the server without authentication
  def self.http_get_request_unauth (reqUrl)
    require 'net/http'
    Rails.logger.debug 'Call to the http GET request module'
    uri = URI.parse('http://eulersbridge.com:8080/dbInterface' + reqUrl)

    http = Net::HTTP.new(uri.host, uri.port)
    #http.use_ssl = true
    #http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    Rails.logger.debug 'Request: ' + uri.to_s
    request = Net::HTTP::Get.new(uri)
    request.add_field('Content-Type', 'application/json')
    request.add_field('Accept', 'application/json')

    Rails.logger.debug(request)
    http.request(request)
  end

  #Function that makes a PUT request to the server with no JSON data as argument
  def self.http_put_request_simple (reqUrl, username, password)
    require 'net/http'
    Rails.logger.debug 'Call to the http PUT request module'
    uri = URI.parse('http://eulersbridge.com:8080/dbInterface' + reqUrl)
    Rails.logger.debug uri
    
    http = Net::HTTP.new(uri.host, uri.port)
    #http.use_ssl = true
    #http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Put.new(uri)
    request.basic_auth username, password
    request.add_field('Content-Type', 'application/json')
    request.add_field('Accept', 'application/json')
    
    Rails.logger.debug(request)
    http.request(request)
  end

  #Function that makes a PUT request to the server with a json object as body
  def self.http_put_request (reqUrl, jsonObject, username, password)
    require 'json'
    require 'net/http'
    Rails.logger.debug 'Call to the http PUT request module'
    uri = URI.parse('http://eulersbridge.com:8080/dbInterface' + reqUrl)

    http = Net::HTTP.new(uri.host, uri.port)
    #http.use_ssl = true
    #http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Put.new(uri)
    request.basic_auth username, password
    request.add_field('Content-Type', 'application/json')
    request.add_field('Accept', 'application/json')
    
    json_data = jsonObject.to_json
    Rails.logger.debug(request)
    Rails.logger.debug(json_data)
    http.request(request, json_data)
  end

  #Function that makes a DELETE request to the server
  def self.http_delete_request (reqUrl, username, password)
    require 'net/http'
    Rails.logger.debug 'Call to the http DELETE request module'
    uri = URI.parse('http://eulersbridge.com:8080/dbInterface' + reqUrl)

    http = Net::HTTP.new(uri.host, uri.port)
    #http.use_ssl = true
    #http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Delete.new(uri)
    #request.basic_auth 'greg.newitt@unimelb.edu.au', 'test123'
    request.basic_auth username, password
    request.add_field('Content-Type', 'application/json')
    request.add_field('Accept', 'application/json')
    
    Rails.logger.debug(request)
    http.request(request)
  end
end
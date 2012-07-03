require 'mechanize'
require 'fb_util/fb_util_error'

class FBUtil
  @graph_url = nil
  @access_token = nil
  @feed = nil
  @account_info = nil
  @debug = nil

  def initialize(access_token, debug = false)
    @debug = debug
    @graph_url = 'https://graph.facebook.com'
    @access_token = access_token
    if @access_token.blank? && !Rails.nil?
      Rails.logger.info 'An access token is required for this class to work'
    end
  end

  # Get the basic account information from facebook
  def get_account_info
    @account_info ||= get_request('/me')
  end

  # Get the users feed
  def get_feed
    @feed ||= get_request('/me/feed')
    # I have no idea why sometimes it uses the data index and sometimes it doesn't....
    begin
      return @feed['data']
    rescue
      return @feed
    end
  end

  # Post a message to the users wall
  # message: text of the message to be posted. Links will not be converted to click able links. Use post_link to post a clickable link (including video)
  def post_status(message)
    post_request('/me/feed', {message: message})
  end

  # Post a picture to the users wall
  # picture_path: the actual file path to the image (no urls)
  # message: the message to be attached to the image if any. Can be null or empty.
  # post_to_feed: true (by default) if you want the picture to be posted to the users wall, false if you want it hidden. This isn't 100% tested.
  def post_picture(picture_path, message, post_to_feed=true)
    File.open(picture_path.to_s.gsub('%20', '\ ').gsub('(', '\(').gsub(')', '\)'), 'rb') do |binary_image|
      if post_to_feed
        post_request('/me/photos', {source: binary_image, message: message})
      else
        post_request('/me/photos', {source: binary_image, message: message, no_story: 'true'})
      end
    end
  end

  # Set an already existing image to be the users cover image
  # picture_id: the facebook id of the image to use as the users cover image. This currently doesn't allow for an offset, but this will be available in the next version.
  def set_as_cover_image(picture_id)
    post_request('/me', {cover: picture_id, no_feed_story: 'true'})
  end

  # Post a clickable link to a users feed (works for youtube videos as well)
  # link: the link (beginning with http:// or https://) that will be displayed in the users feed
  # message: the message to be posted with the link on the feed page
  def post_link(link, message)
    post_request('/me/feed', {link: link, message: message})
  end

  # Post a reply to a status that is already existing on facebook
  # status_id: the facebook id of the status to reply to
  # message: the message to use in the reply
  def reply_to_status(status_id, message)
    post_request('/' + status_id + '/comments', {message: message})
  end

  # Delete a status
  # status_id: the facebook id of the status to delete
  def delete_status(status_id)
    delete_request('/' + status_id)
  end

  # Get statuses from facebook page/account
  def get_statuses
    @statuses ||= get_request('/me/statuses')
    # I have no idea why sometimes it uses the data index and sometimes it doesn't....
    begin
      return @statuses['data']
    rescue
      return @statuses
    end
  end

  # Get the insights of a page (**this doesn't work for profiles**)
  def get_insights
    @insights ||= get_request('/me/insights')
    begin
      return @insights['data']
    rescue
      return @insights
    end
  end

  # Get any fql request
  # Fql cannot be cached since it might be used more than once to gather different data without creating a new facebook api class
  def get_fql(fql)
    get_request('/fql?q=' + CGI.escape(fql))['data']
  end

  # Get pages associated with the account
  def get_pages
    @page ||= get_request('/me/accounts')['data']
  end

  private
  # Execute a get request against the facebook endpoint requested
  # end_point: anything in the url after the graph.facebook.com i.e. /me/accounts
  def get_request(end_point)
    execute_request(end_point, 'get')
  end

  # Send data to the facebook endpoint requested
  # end_point: anything in the url after the graph.facebook.com i.e. /me/accounts
  # parameters: the information to be sent to facebook in a hash
  def post_request(end_point, parameters)
    execute_request(end_point, 'post', parameters)
  end

  # Delete end point from facebook
  def delete_request(end_point)
    execute_request(end_point, 'delete')
  end

  # The actual request send to facebook
  # end_point: anything in the url after the graph.facebook.com i.e. /me/accounts
  # method: the HTTP method used to send or receive information from facebook
  # parameters: the information to be send to facebook in a hash
  def execute_request(end_point, method, parameters = {})
    agent = Mechanize.new
    response = nil
    begin
      if end_point.include? '?'
        url = @graph_url + end_point + '&access_token=' + @access_token
      else
        url = @graph_url + end_point + '?access_token=' + @access_token
      end
      if method == 'get'
        response = agent.get(url)
      elsif method == 'delete'
        response = agent.get(url + '&method=delete')
      elsif method == 'post'
        response = agent.post(url, parameters)
      end
      if @debug && !Rails.nil?
        # Echo the response if we are in development mode
        if Rails.env.development?
          Rails.logger.info 'FB: ' + method.capitalize + end_point
          # Rails.logger.info 'FB Response: ' + response.body
        end
      end
      return (JSON.parse response.body)
    rescue Exception => e
      if !Rails.nil?
        Rails.logger.info e.page.body
        Rails.logger.info 'Raw exception: ' + e.message
        if @debug
          if !(method == 'post')
            Rails.logger.info 'FB: Error executing ' + method + ' request for "' + end_point + '"'
          else
            Rails.logger.info 'FB: Error executing ' + method + ' request for "' + end_point + '" with parameters: ' + parameters.inspect
          end
        end
      end
      return []
    end
  end

  # These are the methods that don't need to be called with an instanciated class because they don't need an access token
  class << self
    # This method will generate the appropriate redirect for dialog oauth calls
    # app_id: your app id from the facebook developer application
    # redirect_uri: the uri that you want facebook to redirect to after the user authorizes your app (you can pass get variables in this if you need to pass variables back to your application i.e. http://example.com/auth?client_id=1)
    # scope: comma seperate list of permissions your application is requesting (https://developers.facebook.com/docs/authentication/permissions/)
    def generate_oauth_redirect(app_id, redirect_uri, scope)
      return "https://www.facebook.com/dialog/oauth?client_id=" + app_id.to_s + "&redirect_uri=" + CGI.escape(redirect_uri.to_s) + '&scope=' + scope.to_s
    end

    # This method will get a long term access token. If you are getting the access_token for a facebook profile this will be valid for 60 days. If you are getting the access_token for a facebook page it be permanent.
    # app_id: your app id assigned from facebook
    # app_secret: your app secret assigned from facebook
    # redirect_uri: A valid redirect uri is required to get access_tokens. You will not be redirected to this uri
    # code: the code sent back from facebook after the user has authorized your application (generate_oauth_redirect will redirect back to your requested uri with the code needed)
    def get_long_access_token(app_id, app_secret, redirect_uri, code)
      begin
        agent = Mechanize.new
        short_access_page = agent.get("https://graph.facebook.com/oauth/access_token?client_id=#{app_id}&client_secret=#{app_secret}&redirect_uri=#{redirect_uri}&code=" + code)
        short_access_token = short_access_page.body.split('&')[0].split('=')[1]
        # This is where we convert the short access token into a long access token
        long_token_page = agent.get("https://graph.facebook.com/oauth/access_token?client_id=#{app_id}&client_secret=#{app_secret}&grant_type=fb_exchange_token&fb_exchange_token=#{short_access_token}")
        return {'access_token' => long_token_page.body.split('=')[1]}
      rescue Mechanize::ResponseCodeError => e
        raise FBUtilError.new(e.response_code, e.page.body)
      end
    end

    # If you already have a short term access token this method will exchange that for a long term access token. 60 days for user accounts and indefinitely for profile pages
    # short_access_token: the access token already assigned to the account. It must be a valid, non-expired access token
    # app_id: your app id assigned from facebook
    # app_secret: your app secret assigned from facebook
    def get_long_from_short_access_token(short_access_token, app_id, app_secret)
      begin
        agent = Mechanize.new
        long_token_page = agent.get("https://graph.facebook.com/oauth/access_token?client_id=#{app_id}&client_secret=#{app_secret}&grant_type=fb_exchange_token&fb_exchange_token=#{short_access_token}")
        return {'access_token' => long_token_page.body.split('=')[1]}
      rescue Mechanize::ResponseCodeError => e
        raise FBUtilError.new(e.response_code, e.page.body)
      end
    end

    # This method will get a short term access token for your application. Generally (1 - 2 hours)
    # app_id: your app id assigned from facebook
    # app_secret: your app secret assigned from facebook
    # redirect_uri: A valid redirect uri is required to get access_tokens. You will not be redirected to this uri
    # code: the code sent back from facebook after the user has authorized your application (generate_oauth_redirect will redirect back to your requested uri with the code needed)
    def get_short_access_token(app_id, app_secret, redirect_uri, code)
      begin
        agent = Mechanize.new
        short_access_page = agent.get("https://graph.facebook.com/oauth/access_token?client_id=#{app_id}&client_secret=#{app_secret}&redirect_uri=#{redirect_uri}&code=" + code)
        if short_access_page.body.include?('expires')
          return {'access_token' => short_access_page.body.split('&')[0].split('=')[1], 'expires' => short_access_page.body.split('&')[1].split('=')[1]}
        else
          return {'access_token' => short_access_page.body.split('=')[1]}
        end
      rescue Mechanize::ResponseCodeError => e
        raise FBUtilError.new(e.response_code, e.page.body)
      end
    end

    # This method will parse out a signed request using all the necessary validation required to find out if a facebook request is completely valid
    # signed_request: the signed request passed in by facebook
    # application_secret: the application secret assigned to your application form facebook
    # max_age: the allowed age of the signed request. Defaults to 1 hour
    def parse_signed_request(signed_request, application_secret, max_age = 3600)
      encoded_signature, encoded_json = signed_request.split('.', 2)
      json = JSON.parse(base64_url_decode(encoded_json))
      encryption_algorithm = json['algorithm']

      if encryption_algorithm != 'HMAC-SHA256'
        raise 'Unsupported encryption algorithm.'
      elsif json['issued_at'] < Time.now.to_i - max_age
        raise 'Signed request too old.'
      elsif base64_url_decode(encoded_signature) != OpenSSL::HMAC.hexdigest('sha256', application_secret, encoded_json).split.pack('H*')
        raise 'Invalid signature.'
      end

      return json
    end

    private
    # This is a modifed Base64 decode method to ensure that the request ends with the proper amount of equals signs. Base64 is supposed to have a multple of 4 characters in it. i.e. 12341234. If it doesn't have a multiple of 4 characters in it then it is supposed to pad the string with equals signs. i.e. 1234123412== This method will do this.
    def base64_url_decode(encoded_url)
      encoded_url += '=' * (4 - encoded_url.length.modulo(4))
      Base64.decode64(encoded_url.gsub('-', '+').gsub('_', '/'))
    end
  end
end

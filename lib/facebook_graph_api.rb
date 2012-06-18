require 'mechanize'

class FacebookGraphAPI
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
end

require 'mechanize'

class FacebookGraphAPI
  @graph_url = nil
  @access_token = nil
  @feed = nil
  @account_info = nil

  def initialize(access_token)
    @graph_url = 'https://graph.facebook.com'
    @access_token = access_token
    if @access_token.blank? && !Rails.nil?
      Rails.logger.info 'An access token is required for this class to work'
    end
  end

  def get_account_info
    @account_info ||= get_request('/me')
  end

  def get_feed
    @feed ||= get_request('/me/feed')
    # I have no idea why sometimes it uses the data index and sometimes it doesn't....
    begin
      return @feed['data']
    rescue
      return @feed
    end
  end

  def post_status(message)
    post_request('/me/feed', {message: message})
  end

  def post_picture(picture_path, message, post_to_feed=true)
    File.open(picture_path.to_s.gsub('%20', '\ ').gsub('(', '\(').gsub(')', '\)'), 'rb') do |binary_image|
      if post_to_feed
        post_request('/me/photos', {source: binary_image, message: message})
      else
        post_request('/me/photos', {source: binary_image, message: message, no_story: 'true'})
      end
    end
  end

  def set_as_cover_image(picture_id)
    post_request('/me', {cover: picture_id, no_feed_story: 'true'})
  end

  def post_link(link, message)
    post_request('/me/feed', {link: link, message: message})
  end

  def reply_to_status(status_id, message)
    post_request('/' + status_id + '/comments', {message: message})
  end

  def delete_status(status_id)
    delete_request('/' + status_id)
  end

  def get_statuses
    @statuses ||= get_request('/me/statuses')
  end

  def get_insights
    @insights ||= get_request('/me/insights')
    begin
      return @insights['data']
    rescue
      return @insights
    end
  end

  # Fql cannot be cached since it might be used more than once to gather different data
  # without creating a new facebook api class
  def get_fql(fql)
    get_request('/fql?q=' + CGI.escape(fql))['data']
  end

  def get_pages
    @page ||= get_request('/me/accounts')['data']
  end

  private
  def get_request(end_point)
    execute_request(end_point, 'get')
  end

  def post_request(end_point, parameters)
    execute_request(end_point, 'post', parameters)
  end

  def delete_request(end_point)
    execute_request(end_point, 'delete')
  end

  def execute_request(end_point, method, parameters = {})
    begin
      agent = Mechanize.new
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
      if !Rails.nil?
        # Echo the response if we are in development mode
        if Rails.env.development?
          Rails.logger.info 'FB: ' + method.capitalize + end_point
          # Rails.logger.info 'FB Response: ' + response.body
        end
      end
      return (JSON.parse response.body)
    rescue Exception => e
      if !Rails.nil?
        if !(method == 'post')
          Rails.logger.info 'FB: Error executing ' + method + ' request for "' + end_point + '"'
        else
          Rails.logger.info 'FB: Error executing ' + method + ' request for "' + end_point + '" with parameters: ' + parameters.inspect
        end
        Rails.logger.info 'Raw exception: ' + e.message
      end
      return []
    end
  end
end

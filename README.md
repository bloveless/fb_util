# Facebook Graph API #

## TODO ##
1. Should have a way to get an access token since the entirety of the api is based off already having an api key. This will come.

## Usage example ##

To get the users feed

**facebook_graph_api** = FacebookGraphAPI.new(<access token>)  
facebook_graph_api.get_feed

## Caching ##

Most of the methods are cache so that each time a class is called it will store the results of any method call. This way if you want to call a message more than one time it will not query from facebook again, but rather return the cached version. The get_fql method is not cache since you could potentially run two different fql queries in the same instantiation of a class.

## Methods ##
_All methods are assuming the use of the above initilization code including a valid access token._  

Get the basic account information from facebook  
**facebook_graph_api**_.get_account_info_

Get the users feed  
**facebook_graph_api**_.get_feed_

Post a message to the users wall  
*  message: text of the message to be posted. Links will not be converted to click able links. Use post_link to post a clickable link (including video)_  
**facebook_graph_api**_.post_status(message)_

Post a picture to the users wall  
*  picture_path: the actual file path to the image (no urls)  
*  message: the message to be attached to the image if any. Can be null or empty.  
*  post_to_feed: true (by default) if you want the picture to be posted to the users wall, false if you want it hidden. **This isn't 100% tested**  
**facebook_graph_api**_.post_picture(picture_path, message, post_to_feed=true)_

Set an already existing image to be the users cover image  
*  picture_id: the facebook id of the image to use as the users cover image. **This currently doesn't allow for an offset, but this will be available in the next version**  
**facebook_graph_api**_.set_as_cover_image(picture_id)_

Post a clickable link to a users feed (works for youtube videos as well)  
*  link: the link (beginning with http:// or https://) that will be displayed in the users feed  
*  message: the message to be posted with the link on the feed page  
**facebook_graph_api**_.post_link(link, message)_

Post a reply to a status that is already existing on facebook
*  status_id: the facebook id of the status to reply to  
*  message: the message to use in the reply  
**facebook_graph_api**_.reply_to_status(status_id, message)

Delete a status  
*  status_id: the facebook id of the status to delete  
**facebook_graph_api**_.delete_status(status_id)

Get statuses from facebook page/account  
**facebook_graph_api**_.get_statuses_

Get the insights of a page (**this doesn't work for profiles**)  
**facebook_graph_api**_.get_insights_

Get any fql request  
*  fql: the facebook query requested  
**facebook_graph_api**_.get_fql(fql)_

Get pages associated with the account  
**facebook_graph_api**_.get_pages_
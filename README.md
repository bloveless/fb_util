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

- - -

Get the basic account information from facebook  

**facebook_graph_api**.get\_account\_info

- - -

Get the users feed  

**facebook_graph_api**.get\_feed

- - -

Post a message to the users wall  
*  message: text of the message to be posted. Links will not be converted to click able links. Use post_link to post a clickable link (including video)_  

**facebook_graph_api**.post\_status(message)

- - -

Post a picture to the users wall  
*  picture\_path: the actual file path to the image (no urls)  
*  message: the message to be attached to the image if any. Can be null or empty.  
*  post\_to\_feed: true (by default) if you want the picture to be posted to the users wall, false if you want it hidden. **This isn't 100% tested**  

**facebook_graph_api**_.post_picture(picture_path, message, post_to_feed=true)_

- - -

Set an already existing image to be the users cover image  
*  picture\_id: the facebook id of the image to use as the users cover image. **This currently doesn't allow for an offset, but this will be available in the next version**  

**facebook_graph_api**.set\_as\_cover\_image(picture\_id)

- - -

Post a clickable link to a users feed (works for youtube videos as well)  
*  link: the link (beginning with http:// or https://) that will be displayed in the users feed  
*  message: the message to be posted with the link on the feed page  

**facebook_graph_api**.post\_link(link, message)

- - - 

Post a reply to a status that is already existing on facebook
*  status\_id: the facebook id of the status to reply to  
*  message: the message to use in the reply  

**facebook_graph_api**.reply\_to\_status(status\_id, message)

- - - 

Delete a status  
*  status\_id: the facebook id of the status to delete  

**facebook_graph_api**.delete_status(status\_id)

- - - 

Get statuses from facebook page/account  

**facebook_graph_api**.get\_statuses

- - - 

Get the insights of a page (**this doesn't work for profiles**)  

**facebook_graph_api**.get\_insights

- - - 

Get any fql request  
*  fql: the facebook query requested  

**facebook_graph_api**.get\_fql(fql)

- - -

Get pages associated with the account  

**facebook_graph_api**.get\_pages
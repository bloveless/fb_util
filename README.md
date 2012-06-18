# FBUtil #

## TODO ##
1. Should have a way to get an access token since the entirety of the api is based off already having an api key. This will come.

## Usage example ##

To get the users feed

Get a facebook graph api object  
 * access_token: OAuth access token from facebook to access the users account  
 * debug: whether or not to display request debug information in rails development environment.  

**fb_util** = FBUtil.new(access_token, debug=false)  
fb_util.get_feed

## Caching ##

Most of the methods are cached so that each time a method is called it will store the results and return those results on any subsequent calls. This way if you want to call a message more than one time it will not query from facebook again, but rather return the cached version. The get_fql method is not cached since you could potentially run two different fql queries in the same instantiation of a class.

## Methods ##
_All methods are assuming the use of the above initilization code including a valid access token._  

- - -

Get the basic account information from facebook  

**fb_util**.get\_account\_info

- - -

Get the users feed  

**fb_util**.get\_feed

- - -

Post a message to the users wall  
*  message: text of the message to be posted. Links will not be converted to click able links. Use post_link to post a clickable link (including video)_  

**fb_util**.post\_status(message)

- - -

Post a picture to the users wall  
*  picture\_path: the actual file path to the image (no urls)  
*  message: the message to be attached to the image if any. Can be null or empty.  
*  post\_to\_feed: true (by default) if you want the picture to be posted to the users wall, false if you want it hidden. **This isn't 100% tested**  

**fb_util**_.post_picture(picture_path, message, post_to_feed=true)_

- - -

Set an already existing image to be the users cover image  
*  picture\_id: the facebook id of the image to use as the users cover image. **This currently doesn't allow for an offset, but this will be available in the next version**  

**fb_util**.set\_as\_cover\_image(picture\_id)

- - -

Post a clickable link to a users feed (works for youtube videos as well)  
*  link: the link (beginning with http:// or https://) that will be displayed in the users feed  
*  message: the message to be posted with the link on the feed page  

**fb_util**.post\_link(link, message)

- - - 

Post a reply to a status that is already existing on facebook
*  status\_id: the facebook id of the status to reply to  
*  message: the message to use in the reply  

**fb_util**.reply\_to\_status(status\_id, message)

- - - 

Delete a status  
*  status\_id: the facebook id of the status to delete  

**fb_util**.delete_status(status\_id)

- - - 

Get statuses from facebook page/account  

**fb_util**.get\_statuses

- - - 

Get the insights of a page (**this doesn't work for profiles**)  

**fb_util**.get\_insights

- - - 

Get any fql request  
*  fql: the facebook query requested  

**fb_util**.get\_fql(fql)

- - -

Get pages associated with the account  

**fb_util**.get\_pages

## Class Methods ##
These methods don't need a class to be instantiated since these methods don't need an access token  

- - -

This method will parse out a signed request using all the necessary validation required to find out if a facebook request is completely valid  
*  signed_request: the signed request passed in by facebook  
*  application_secret: the application secret assigned to your application from facebook  
*  max_age: the allowed age of the signed request. Defaults to 1 hour  

**FBUtil**::parse_signed_request(signed_request, application_secret, max_age = 3600)

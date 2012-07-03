# FBUtil #

FBUtil came from my dealing with other facebook gems. I really really like it when the output from a third party api is returned in the same format as the third party api, so that I can parse the raw data and use it like I want to, rather than having to conform to someones idea of what it should look like. Out of this idea came FBUtil. It will perform the queries for you, with a little magic to get everything working and will return the raw data back from facebook which you may do with what you'd like. So far I have only build the magic for the functions that I have used, but if you'd like to request additional functionality I would be more than happy to implement it at my leasure. But if you take a look at the source code I think you'll realize that it is very simple to add on to this library... meaning... you should try it and make a pull request. That would make me very happy!

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

This method will generate the appropriate redirect for dialog oauth calls
*  app_id: your app id from the facebook developer application  
*  redirect_uri: the uri that you want facebook to redirect to after the user authorizes your app (you can pass get variables in this if you need to pass variables back to your application i.e. http://example.com/auth?client_id=1)  
*  scope: comma seperate list of permissions your application is requesting (https://developers.facebook.com/docs/authentication/permissions/)  

**FBUtil**.generate_oauth_redirect(app_id, redirect_uri, scope)

- - -

This method will get a short term access token for your application. Generally (1 - 2 hours)
*  app_id: your app id assigned from facebook  
*  app_secret: your app secret assigned from facebook  
*  redirect_uri: A valid redirect uri is required to get access_tokens. You will not be redirected to this uri  
*  code: the code sent back from facebook after the user has authorized your application (generate_oauth_redirect will redirect back to your requested uri with the code needed)  

**FBUtil**.get_short_access_token(app_id, app_secret, redirect_uri, code)

- - -

This method will get a long term access token. If you are getting the access_token for a facebook profile this will be valid for 60 days. If you are getting the access_token for a facebook page it be permanent.
*  app_id: your app id assigned from facebook   
*  app_secret: your app secret assigned from facebook  
*  redirect_uri: A valid redirect uri is required to get access_tokens. You will not be redirected to this uri  
*  code: the code sent back from facebook after the user has authorized your application (generate_oauth_redirect will redirect back to your requested uri with the code needed)  

**FBUtil**.get_long_access_token(app_id, app_secret, redirect_uri, code)

- - -

If you already have a short term access token this method will exchange that for a long term access token. 60 days for user accounts and indefinitely for profile pages
*  short_access_token: the access token already assigned to the account. It must be a valid, non-expired access token  
*  app_id: your app id assigned from facebook  
*  app_secret: your app secret assigned from facebook  

**FBUtil**.get_long_from_short_access_token(short_access_token, app_id, app_secret)

- - -

This method will parse out a signed request using all the necessary validation required to find out if a facebook request is completely valid  
*  signed_request: the signed request passed in by facebook  
*  application_secret: the application secret assigned to your application from facebook  
*  max_age: the allowed age of the signed request. Defaults to 1 hour  

**FBUtil**.parse_signed_request(signed_request, application_secret, max_age = 3600)

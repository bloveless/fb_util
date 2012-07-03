Gem::Specification.new do |s|
  s.name        = 'fb_util'
  s.version     = '0.9'
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.summary     = "Oh my simple facebook util"
  s.description = "A quick utility class to work with the facebook graph api and misc facebook functions, will be version 1 as soon as I figure out tests for this."
  s.authors     = ["Brennon Loveless"]
  s.email       = 'brennon@fritzandandre.com'
  s.files       = ["lib/fb_util.rb", "lib/fb_util/fb_util_error.rb"]
  s.homepage    = 'https://github.com/jbrennon/fb_util'
  s.add_dependency('mechanize', '~> 2.3')
end

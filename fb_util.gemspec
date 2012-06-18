Gem::Specification.new do |s|
  s.name        = 'fb_util'
  s.version     = '0.0.7.1'
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.summary     = "Oh my simple facebook util"
  s.description = "A quick utility class to work with the facebook graph api and misc facebook functions"
  s.authors     = ["Brennon Loveless"]
  s.email       = 'brennon@fritzandandre.com'
  s.files       = ["lib/fb_util.rb"]
  s.homepage    = 'https://github.com/jbrennon/fb_util'
  s.add_dependency('mechanize', '~> 2.3')
end

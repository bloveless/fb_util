Gem::Specification.new do |s|
  s.name        = 'facebook_graph_api'
  s.version     = '0.0.5'
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.summary     = "Oh my simple facebook graph api"
  s.description = "A quick simple api to work with the facebook graph api"
  s.authors     = ["Brennon Loveless"]
  s.email       = 'brennon@fritzandandre.com'
  s.files       = ["lib/facebook_graph_api.rb"]
  s.homepage    = 'http://rubygems.org/gems/facebook_graph_api'
  s.add_dependency('mechanize', '~> 2.3')
end
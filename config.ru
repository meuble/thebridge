# ===========
# = WARNING !=
# add line in linkage.rb 
# run "ln -nfs #{shared_path}/config/APPLICATION/koala.yml #{release_path}/config/APPLICATION/koala.yml"
# ===========
require 'rubygems'
require 'bundler'
Bundler.require

require "./app.rb"

def route_with(routes)
  routes = routes.inject({}) do |new_routes, route|
    url = route.first
    app = route.last
    
    url += '/' if url !~ /\//
    
    new_routes["http://#{url}"] = app
    new_routes["https://#{url}"] = app
    new_routes
  end
  
  run Rack::URLMap.new(routes)
end

route_with({
  "localhost" => Messenger,
  "meuble.pagekite.me" => Messenger
})


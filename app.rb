require 'bundler' #require bundler
Bundler.require #require everything in bundler in gemfile
require_relative './lib/facebook_scraper.rb'
require_relative './lib/mailgun.rb'
require 'sinatra'

get '/' do
  set :server, 'thin'
  erb :index # This tells your program to use the html associated with the index.erb file in your browser.
end

post '/' do
  puts params[:email]
  if params[:email] and params[:password]
    @facebook_scraper=FacebookScraper.new(params[:email], params[:password])
    @facebook_scraper.update_names(5) 
  end
  erb :index
end
require File.expand_path('../counter.rb', __FILE__)
use Rack::ShowExceptions
run MyApp.new    
# require 'rubygems'
# require 'sinatra'
# require './counter'
 
# run Sinatra::Application
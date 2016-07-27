require 'sinatra'
require 'json'
require 'slim'
require 'thin'

class MyThinBackend < ::Thin::Backends::TcpServer
  def initialize(host, port, options)
    super(host, port)
    @ssl = true
    @ssl_options = options
  end
end

configure do
  set :environment, :production
  set :bind, '0.0.0.0'
  set :port, 443
  set :server, "thin"
  class << settings
    def server_settings
      {
        :backend          => MyThinBackend,
        :private_key_file => File.dirname("/etc/apache2/ssl") + "/server.key",
        :cert_chain_file  => File.dirname("/etc/apache2/ssl") + "/server.crt",
        :verify_peer      => false
      }
    end
  end
end

get '/' do 
  slim :index 
end

# post text
post '/' do
  content_type :json

  @text = params[:text]

  def count_words(string)
    string = string.downcase.gsub(/[^\w']+/, ' ')
    words = string.split(/[,\s]/)
    counting = Hash.new(0)
    words.each { |word| counting[word.downcase] += 1 }
    counting = counting.sort_by { |word,count| count }.reverse!
    return counting.to_h
  end

  word_count = count_words(params[:text])
  counter = (params[:text]).scan(/\w+/).size

  totality = Hash.new
  totality["count"] = counter
  totality["words"] = word_count
  @counted = totality.to_json

end


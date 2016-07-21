require 'sinatra'
require 'json'
require 'words_counted'
require 'slim'
require 'webrick'
require 'webrick/https'
require 'openssl'

CERT_PATH = '/etc/apache2/ssl/'

webrick_options = {
        :Port               => 8443,
        :Logger             => WEBrick::Log::new($stderr, WEBrick::Log::DEBUG),
        :DocumentRoot       => "/var/www/html",
        :SSLEnable          => true,
        :SSLVerifyClient    => OpenSSL::SSL::VERIFY_NONE,
        :SSLCertificate     => OpenSSL::X509::Certificate.new(  File.open(File.join(CERT_PATH, "server.crt")).read),
        :SSLPrivateKey      => OpenSSL::PKey::RSA.new(          File.open(File.join(CERT_PATH, "server.key")).read),
        :SSLCertName        => [ [ "CN",WEBrick::Utils::getservername ] ]
}

Rack::Handler::WEBrick.run MyServer, webrick_options


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
  counter = WordsCounted.count(params[:text])
  counter.token_count
  counter.token_frequency

  totality = Hash.new
  totality["count"] = counter.token_count
  totality["words"] = word_count
  @counted = totality.to_json

end

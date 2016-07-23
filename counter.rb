require 'sinatra'
require 'json'
require 'slim'

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


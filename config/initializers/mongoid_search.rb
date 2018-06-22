Mongoid::Search.setup do |config|
  config.allow_empty_search = true
  config.minimum_word_size = 1
end

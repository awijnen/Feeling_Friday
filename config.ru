# config.ru

require './feelingfriday'
run Sinatra::Application

$stdout.sync = true

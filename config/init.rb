require 'sinatra/sequel'
require 'sqlite3'

configure :development do
  set :database, 'sqlite://tmp/development.sqlite'
end

require './config/migrations'

Dir["models/**/*.rb"].each{|model|
  require model
}

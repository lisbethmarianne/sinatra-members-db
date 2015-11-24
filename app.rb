require 'sinatra'
require 'sinatra/activerecord'
require './config/environments' # database configuration
require './models/member'

if Sinatra::Base.environment == :development
  require 'dotenv'
  Dotenv.load
end

class NameValidator
  def initialize(name, names)
    @name = name.to_s
    @names = names
    @messages = []
  end

  def valid?
    validate
    @messages.empty?
  end

  def message
    @messages.first
  end

  private

    def validate
      if @name.empty?
        @messages << "You need to enter a name."
      elsif @names.include?(@name)
        @messages << "#{@name} is already included in our list."
      end
    end
end

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [ENV['MEMBERS_USERNAME'], ENV['MEMBERS_PASSWORD']]
  end
end

enable :sessions

get '/' do
  redirect to('/members')
end

get '/login' do
  protected!
  redirect to('/members')
end

get '/members' do
  @message = session.delete(:message)
  @members = Member.all.order(:name)
  erb :index
end

get '/members/new' do
  protected!
  @message = session.delete(:message)
  @member = Member.new
  erb :new
end

post '/members' do
  protected!
  @name = params[:name]
  @members = Member.all
  @names = []
  @members.each do |member|
    @names << member.name
  end

  validator = NameValidator.new(@name, @names)

  if validator.valid?
    @member = Member.new(params)
    @member.save
    session[:message] = "Successfully stored the member #{@name}."
    redirect "/members/#{@member.id}"
  else
    @message = validator.message
    erb :new
  end
end

get '/members/:id' do
  @message = session.delete(:message)
  @member = Member.find(params[:id])
  erb :show
end

get '/members/:id/edit' do
  protected!
  @member = Member.find(params[:id])
  erb :edit
end

put '/members/:id' do
  protected!
  @name = params[:name]
  @members = Member.all
  @names = []
  @members.each do |member|
    @names << member.name
  end

  validator = NameValidator.new(@name, @names)

  if validator.valid?
    @member = Member.find(params[:id])
    @member.update(:name => params[:name])
    session[:message] = "Successfully updated the member #{@name}."
    redirect "/members/#{@member.id}"
  else
    @message = validator.message
    erb :edit
  end
end

get "/members/:id/delete" do
  protected!
  @member = Member.find(params[:id])
  erb :delete
end

delete '/members/:id' do
  protected!
  @member = Member.find(params[:id])
  @member.delete
  session[:message] = "Successfully deleted."
  redirect '/members'
end

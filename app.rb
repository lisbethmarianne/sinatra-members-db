require 'sinatra'
require 'sinatra/activerecord'
require './config/environments' # database configuration
require './models/member'

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

enable :sessions

get '/members' do
  @message = session.delete(:message)
  @members = Member.all.order(:name)
  erb :index
end

get '/members/new' do
  @message = session.delete(:message)
  @member = Member.new
  erb :new
end

post '/members' do
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
  @member = Member.find(params[:id])
  erb :edit
end

put '/members/:id' do
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
  @member = Member.find(params[:id])
  erb :delete
end

delete '/members/:id' do
  @member = Member.find(params[:id])
  @member.delete
  session[:message] = "Successfully deleted."
  redirect '/members'
end
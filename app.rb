require 'sinatra'
require 'sinatra/activerecord'
require './config/environments' # database configuration
require './models/member'


get '/members' do
  @members = Member.all
  erb :index
end

get '/members/new' do
  @member = Member.new
  erb :new
end

post '/members' do
  member = Member.new(params).save or halt 400
  redirect "/members"
end

get '/members/:id' do
  @member = Member.find(params[:id]) or halt 404
  erb :show
end

get '/members/:id/edit' do
  @member = Member.find(params[:id]) or halt 404
  erb :edit
end

put '/members/:id' do
  @member = Member.find(params[:id]) or halt 404
  @member.update(:name => params[:name]) or halt 400
  redirect "/members/#{@member.id}"
end

get "/members/:id/delete" do
    @member = Member.find(params[:id])
    erb :delete
  end

delete '/members/:id' do
  @member = Member.find(params[:id]) or halt 404
  @member.delete
  redirect '/members'
end
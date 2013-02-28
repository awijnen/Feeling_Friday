require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'dm-postgres-adapter'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

class Note
  include DataMapper::Resource

  # setting up a Notes table
  # setting up database schema with 5 columns
  property :id, Serial # serial will auto increment
  property :content, Text, :required => true
  property :complete, Boolean, :required => true, :default => false
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :comments
end

class Comment
  include DataMapper::Resource

  property :id, Serial
  property :content, Text
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :note
end

DataMapper.finalize.auto_upgrade! # automatically update the database to contain the tables and fields we have set, and to do so again if we make any changes to the schema

get '/' do
  @notes = Note.all :order => :id.desc
  @title = "All Emotions"
  erb :home
end

post '/post' do
  n = Note.new
  n.content = params[:content]
  n.created_at = Time.now
  n.updated_at = Time.now
  n.save
  redirect '/'
end

# get '/migrate' do
#   DataMapper.auto_migrate!
#   redirect '/'
# end

get '/:id' do  
  @note = Note.get params[:id]  
  @title = "Edit note ##{params[:id]}"  
  erb :edit  
end 

put '/:id' do  
  n = Note.get params[:id]  
  n.content = params[:content]  
  n.complete = params[:complete] ? 1 : 0  
  n.updated_at = Time.now  
  n.save  
  redirect '/'  
end

get '/:id/delete' do  
  @note = Note.get params[:id]  
  @title = "Confirm deletion of note ##{params[:id]}"  
  erb :delete  
end

delete '/:id' do  
  n = Note.get params[:id]  
  n.destroy  
  redirect '/'  
end 

get '/:id/complete' do  
  n = Note.get params[:id]  
  n.complete = n.complete ? 0 : 1 # flip it  
  n.updated_at = Time.now  
  n.save  
  redirect '/'  
end

post '/comment' do
  p params['id'], params['content']
  note = Note.get(params['id'])
  comment = Comment.new
  comment.content = params['content']
  note.comments << comment
  note.save
  redirect '/'
end



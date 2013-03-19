# Include the necesarry gems #

require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'dm-postgres-adapter'

# Set up the Database #

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


# Routes #

# Get all notes from the database for display
get '/' do
  @notes = Note.all :order => :id.desc
  @title = "All Emotions"
  erb :home
end

# Create a new note
post '/post' do
  n = Note.new
  n.content = params[:content]
  n.created_at = Time.now
  n.updated_at = Time.now
  n.save
  redirect '/'
end

# Display an individual note using it's 'id', and present the user with an edit view.
get '/:id' do  
  @note = Note.get params[:id]  
  @title = "Edit note ##{params[:id]}"  
  erb :edit  
end 

# Edit an individual note, and update the database using the HTTP verb 'put'
put '/:id' do  
  n = Note.get params[:id]  
  n.content = params[:content]  
  n.complete = params[:complete] ? 1 : 0  
  n.updated_at = Time.now  
  n.save  
  redirect '/'  
end

# Display an individual note using it's 'id', and present the user with a delete view.
get '/:id/delete' do  
  @note = Note.get params[:id]  
  @title = "Confirm deletion of note ##{params[:id]}"  
  erb :delete  
end

# Delete an individual note, and remove it from the database using the HTTP verb 'delete'
delete '/:id' do  
  n = Note.get params[:id]  
  n.destroy  
  redirect '/'  
end 

# flip complete status
get '/:id/complete' do  
  n = Note.get params[:id]  
  n.complete = n.complete ? 0 : 1 # flip it  
  n.updated_at = Time.now  
  n.save  
  redirect '/'  
end

# Post a comment to a note
post '/comment' do
  p params['id'], params['content']
  note = Note.get(params['id'])
  comment = Comment.new
  comment.content = params['content']
  note.comments << comment
  note.save
  redirect '/'
end



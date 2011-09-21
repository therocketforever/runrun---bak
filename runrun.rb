require 'sinatra'
require 'datamapper'

SITE_TITLE = "RUNRUN Bicycle Couriers"
SITE_DESCRIPTION = "Fast, Affordable, Reliable. Anywhere in Ann Arbor"

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/runrun.db")

# Define waybills Table.
class Waybill
  include DataMapper::Resource
  property :id, Serial
  property :number, String
  property :account, String
  property :charge, Float
  property :origin, String
  property :destination, String
  property :delivered, Boolean, :required => true, :default => false
  property :delivered_by, Integer
  property :delivered_at, DateTime
  property :created_at, DateTime
  property :updated_at, DateTime
  property :signature, String
end

DataMapper.finalize.auto_upgrade!

# Site Home
get '/' do
  @title = 'Home'
  erb :home
end

# List all Waybills.
get '/waybills' do
  @waybills = Waybill.all :order => :id.desc
  @title = 'All Waybills'
  erb :'waybills/waybills'
end

# Create a new Waybill
post '/waybills' do
  w = Waybill.new
  w.number = params[:number]
  w.account = params[:account]
  w.charge = params[:charge]
  w.origin = params[:origin]
  w.destination = params[:destination]
  w.delivered = params[:delivered] ? 1 : 0
  w.delivered_by = params[:delivered_by]
  w.save
  redirect '/waybills'
end

# Edit Waybill by ID.
get '/waybills/:id' do
  @waybill = Waybill.get params[:id]
  @title = "Edit waybill #{params[:id]}"
  erb :'waybills/edit'
end

put '/waybills/:id' do
  w = Waybill.get params[:id]
  w.number = params[:number]
  w.account = params[:account]
  w.charge = params[:charge]
  w.origin = params[:origin]
  w.destination = params[:destination]
  w.delivered_by = params[:delivered_by]
  w.signature = params[:signature]
  w.updated_at = Time.now
  w.save
  redirect '/waybills'
end

# Delete Waybill by ID.
get '/waybills/:id/delete' do
  @waybill = Waybill.get params[:id]
  @title = "Confirm deletion of Waybill ##{params[:id]}"
  erb :'waybills/delete'
end

delete '/waybills/:id' do
  w = Waybill.get params[:id]
  w.destroy
  redirect '/waybills'
end

# Set waybill status to 'Delivered'
get '/waybills/:id/delivered' do
  w = Waybill.get params[:id]
  w.delivered = w.delivered ? 0 : 1 #flip it
  w.delivered_at = Time.now
  w.updated_at = Time.now
  w.save
  redirect '/waybills'
end
ENV['RACK_ENV'] ||= 'development'

require 'bundler/setup'
Bundler.require :default, ENV['RACK_ENV'].to_sym

require_relative 'db'
require_relative 'lib/lockable'
require_relative 'lib/asset'
require_relative 'lib/chunk'

before %r{^/(\d+)} do
  @asset = Asset[params[:captures].first] || not_found
end

get '/new' do
  respond_with :'assets/new'
end

get '/:id/chunks/:number' do
  chunk = Chunk[params[:id], params[:number]] || not_found
  200
end

# to simplify linking
get '/:id/media' do
  content_type @asset.type
  send_file @asset.path
end

get '/:id' do
  respond_with :'assets/show', asset: @asset
end

get '/' do
  respond_with :'assets/index', assets: Asset.all
end

post '/' do
  file = params[:asset][:file]
  
  @asset = Asset.new(
    name:     file[:filename],
    type:     file[:type],
    tempfile: file[:tempfile] ? file[:tempfile] : nil,
    size:     file[:tempfile] ? file[:tempfile].size : file[:size]
  )
  @asset.save
  
  headers 'Location' => url("/#{@asset.id}")
  respond_to do |f|
    f.json { 201 }
    f.html { redirect to "/#{@asset.id}" unless request.xhr? }
  end
end

put '/:id/chunks/:number' do
  data = request.body.read
  
  @chunk = Chunk.new(
    asset_id:   params[:id],
    number:     params[:number],
    data:       data,
    size:       data.size
  )
  @chunk.save
  
  headers 'Location' => url("/#{@chunk.asset_id}/chunks/#{@chunk.number}")
  
  respond_to do |f|
    f.json { 201 }
    f.html { redirect to "/#{@chunk.asset_id}/chunks/#{@chunk.number}" unless request.xhr? }
  end
end

delete '/:id' do
  @asset.destroy
  
  respond_to do |f|
    f.json { 204 }
    f.html { redirect to '/' }
  end
end

error Sequel::ValidationFailed, Sequel::HookFailed do
  respond_to do |f|
    f.json { 422 }
    f.html { redirect back }
  end
end


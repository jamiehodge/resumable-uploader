require 'bundler/setup'
Bundler.require

DB = Sequel.sqlite

DB.create_table :assets do
  primary_key :id
  
  String      :name
  String      :type
  
  String      :description, text: true
  
  FalseClass  :complete
end

class Asset < Sequel::Model
  
  def after_create
    FileUtils.rm media, force: true
  end
  
  def media
    File.join('media', id.to_s + File.extname(name))
  end
  
  def append(data)
    File.extend(Lockable).lock(media) do |f|
      f.write data
    end
  end
end

module Lockable
  def lock(filename, mode='a', &block)
    File.open(filename, mode) do |f|
      begin
        f.flock File::LOCK_EX
        yield f
      ensure
        f.flock File::LOCK_UN
      end
    end
  end
end

helpers do
  def content_range
    range, total = env['HTTP_CONTENT_RANGE'].split.last.split('/')
    first, last = range.split('-')
    {first: first.to_i, last: last.to_i, total: total.to_i}
  end
end

get '/js/:name.js' do
  coffee params[:name].intern
end

get '/css/:name.css' do
  sass params[:name].intern
end

get '/new' do
  slim :new
end

post '/' do
  asset = Asset.create(
    name: params[:file][:filename],
    type: params[:file][:type],
    description: params[:description]
  )
  FileUtils.mv(params[:file][:tempfile], asset.media) if params[:file][:tempfile]
  
  headers 'Location' => url("/#{asset.id}")
  204
end

before %r{^/(?<id>\d+)/?.*} do
  halt 404 unless @asset = Asset[params[:id]]
end

get '/:id/media' do
  halt 200 unless File.exist?(@asset.media)

  content_type @asset.type
  send_file @asset.media, disposition: 'inline'
end

put '/:id/media' do
  # halt 400 if rand <= 0.5
  
  halt 400 if @asset.complete || content_range[:first] != 
    (File.exist?(@asset.media) ? File.size(@asset.media) : 0)
  
  @asset.append(request.body.read)
  
  @asset.update(complete: true) if content_range[:last] == content_range[:total]
  
  headers 'Location' => url("/#{@asset.id}")
  204
end

get '/:id' do
  slim :show, locals: {asset: @asset}
end
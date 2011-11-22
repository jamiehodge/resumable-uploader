require 'bundler/setup'
Bundler.require

DB = Sequel.sqlite

DB.create_table :assets do
  primary_key :id
  String      :name
  String      :type
  Integer     :size
end

DB.create_table :uploads do
  primary_key :id
  foreign_key :asset_id, :assets
  
  String  :name
  Integer :position, default: 0
  Integer :total, default: 0
end

class Asset < Sequel::Model
  one_to_many :uploads
  
  def after_create
    FileUtils.mkdir_p(dir)
  end
  
  def dir
    File.expand_path(File.join('public', 'assets', id.to_s))
  end
  
  def path
    File.expand_path(File.join(dir, name))
  end
end

class Upload < Sequel::Model
  many_to_one :asset
  
  def after_create
    FileUtils.mkdir_p(dir)
  end
  
  def before_destroy
    FileUtils.mv(path, asset.path)
    FileUtils.rmdir(dir)
  end
  
  def dir
    File.expand_path(File.join('public', 'uploads', id.to_s))
  end
  
  def path
    File.join(dir, name)
  end
  
  def write_range(data)
    File.lock(path) do |f|
      f.seek(position, IO::SEEK_SET)
      f.write data
    end
  end
end

module Lockable
  def lock(filename, &block)
    File.open(filename, File::RDWR|File::CREAT) do |f|
      begin
        f.flock File::LOCK_EX
        yield f
      ensure
        f.flock File::LOCK_UN
      end
    end
  end
end
File.extend(Lockable)

helpers do
  def content_range
    range, total = env['HTTP_CONTENT_RANGE'].split.last.split('/')
    first, last = range.split('-')
    {first: first, last: last, total: total}
  end
end

get '/assets/new' do
  slim :new
end

get '/assets/:id' do
  send_file Asset[params[:id]].path
end

post '/assets/' do
  asset = Asset.create(params)
  upload = asset.add_upload(name: params[:name], total: asset.size)
  headers 'Location' => url("/uploads/#{upload.id}")
  204
end

put '/uploads/:id' do
  upload = Upload[params[:id]]
  halt 400 unless content_range[:first].to_i == upload.position
  
  upload.write_range(request.body.read)
  
  if content_range[:last].to_i == upload.total
    upload.destroy
    headers 'Location' => "/assets/#{upload.asset.id}"
    halt 204
  end
  
  upload.update(position: content_range[:last].to_i + 1)
  headers 'Range' => "1-#{upload.position}"
  308
end

get '/js/:name.js' do
  coffee params[:name].intern
end

get '/css/:name.css' do
  sass params[:name].intern
end

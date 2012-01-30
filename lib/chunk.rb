class Chunk < Sequel::Model
  unrestrict_primary_key
  
  many_to_one :asset
  
  attr_accessor :data
  
  def after_create
    super
    asset.append(data)
  end
  
  def after_destroy
    FileUtils.rm path if File.exist? path
  end
  
  def path
    File.join asset.base_dir, number.to_s
  end
end
class Asset < Sequel::Model
  
  one_to_many :chunks
  
  attr_accessor :tempfile
  
  def after_create
    super
    FileUtils.mkdir_p base_dir
    
    if tempfile
      FileUtils.mv(tempfile, path)
      update(complete: true)
    end
  end
  
  def before_destroy
    FileUtils.rm_r base_dir if File.exist? base_dir
    super
  end
  
  def append(data)
    File.extend(Lockable).lock(path) do |file|
      file.write data
    end
    update(complete: true) if chunks_dataset.sum(:size) == size
  end
  
  def base_dir
    File.join 'assets', id.to_s
  end
  
  def path
    File.join base_dir, name
  end
end
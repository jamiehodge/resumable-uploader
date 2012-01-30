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
require 'active_hash'

class Infra::DiskType < Infra::Base
  attr_accessor :id
  attr_accessor :name
  attr_accessor :path # extract to FileDiskType
  attr_accessor :enabled


  def self.all
    Wvm::StoragePool.all
  end

  def self.find id
    Wvm::StoragePool.find id
  end
end

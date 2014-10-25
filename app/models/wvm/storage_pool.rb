class Wvm::StoragePool < Wvm::Base
  def self.all
    response = call :get, '/1/storages'

    pools = response.storages.map do |remote_pool|
      local_pool = to_local remote_pool.name
      next unless local_pool

      Infra::DiskType.new \
          id: remote_pool.name,
          name: local_pool[:name],
          enabled: remote_pool.enabled
    end

    pools.compact
  end

  def self.find id
    raise unless id =~ /\A[a-zA-Z-]+\Z/

    local_pool = to_local id
    raise unless local_pool

    storage_pool = call :get, "/1/storage/#{id}"

    Infra::DiskType.new \
        id: storage_pool.pool,
        name: local_pool[:name],
        path: storage_pool.path,
        enabled: storage_pool.state == 1
  end

  def self.to_local remote_pool
    hypervisor[:storages].find do |storage|
      storage[:id] == remote_pool
    end
  end
end

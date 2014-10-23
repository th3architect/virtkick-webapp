require 'ipaddress'

class Wvm::Setup < Wvm::Base
  def self.setup
    id = create_connection
    create_network id
    create_storage_pools id

    # TODO: save response.id
  end

  private
  def self.create_connection
    response = call :post, '/servers', host_ssh_add: '',
        name: hypervisor[:name],
        hostname: hypervisor[:host],
        login: hypervisor[:login]

    response.id
  end

  def self.create_network id
    network = hypervisor[:network]
    call :post, "/#{id}/networks/", create: '',
        name: network[:id],
        subnet: network[:address],
        dhcp: network[:dhcp],
        forward: network[:type],
        bridge_name: ''
  end

  def self.create_storage_pools id
    hypervisor[:storages].each do |storage|
      create_storage id, storage
    end

    create_storage id, hypervisor[:iso]
  end

  def self.create_storage id, storage
    call :post, "/#{id}/storages", create: '',
        stg_type: 'dir',
        name: storage[:id],
        target: storage[:path]
  end
end

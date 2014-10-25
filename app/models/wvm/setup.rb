require 'ipaddress'

class Wvm::Setup < Wvm::Base
  class Error < Exception
  end

  def self.setup
    id = create_connection
    create_network id
    all_storages.each do |storage|
      create_storage id, storage[:id], storage[:path]
    end

    # TODO: save response.id for future use
  end

  def self.check
    id = find_connection
    find_network id
    all_storages.each do |storage|
      find_storage id, storage[:id]
    end
  end

  private
  def self.find_connection
    response = call :get, '/servers'
    host_info = response.hosts_info.find do |host_info|
      host_info.hostname == hypervisor[:host]
    end

    raise Error, 'hypervisor not configured' unless host_info
    host_info.id
  end

  def self.create_connection
    response = call :post, '/servers', host_ssh_add: '',
        name: hypervisor[:name],
        hostname: hypervisor[:host],
        login: hypervisor[:login]

    response.id
  end

  def self.find_network id
    call :get, "/#{id}/network/#{hypervisor[:network][:id]}"
    # TODO: validate properties
  rescue Errors
    raise Error, 'network not configured'
  end

  def self.create_network id
    network = hypervisor[:network]
    call :post, "/#{id}/networks", create: '',
        name: network[:id],
        subnet: network[:address],
        dhcp: network[:dhcp],
        forward: network[:type],
        bridge_name: ''
  end

  def self.find_storage id, storage_id
    call :get, "/#{id}/storage/#{storage_id}"
  end

  def self.create_storage id, storage_id, storage_path
    call :post, "/#{id}/storages", create: '',
        stg_type: 'dir',
        name: storage_id,
        target: storage_path
  end

  def self.all_storages
    hypervisor[:storages] + [hypervisor[:iso]]
  end
end

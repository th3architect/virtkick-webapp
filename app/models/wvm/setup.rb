require 'ipaddress'

class Wvm::Setup < Wvm::Base
  class Error < Exception
  end

  def self.setup
    handle_exceptions do
      id = create_connection_if_needed
      create_network_if_needed id
      all_storages.each do |storage|
        create_storage_if_needed id, storage
      end
    end

    # TODO: save response.id for future use
  end

  def self.check
    handle_exceptions do
      id = find_connection
      find_network id
      all_storages.each do |storage|
        find_storage id, storage[:id]
      end
    end
  end

  private
  def self.handle_exceptions
    yield
  rescue Timeout::Error
    raise Error, \
        'Could not connect to localhost hypervisor. Is OpenSSH server running? Is libvirtd running? ' +
        'Can "virtkick" user execute virsh?'
  end

  # Connection

  def self.create_connection_if_needed
    id = begin
      find_connection
    rescue Exception
      create_connection
    end
  end

  def self.find_connection
    response = Timeout.timeout 1.second do
      call :get, '/servers'
    end

    host_info = response.hosts_info.find do |host_info|
      host_info.hostname == hypervisor[:host]
    end

    if host_info.nil?
      raise Error, 'Libvirt connection not configured.' unless host_info
    elsif host_info.status != 1
      raise Timeout::Error
    else
      host_info.id
    end
  end

  def self.create_connection
    Timeout.timeout 1.second do
      response = call :post, '/servers', host_ssh_add: '',
          name: hypervisor[:name],
          hostname: hypervisor[:host],
          login: hypervisor[:login]

      response.id
    end
  end

  # Network

  def self.create_network_if_needed id
    begin
      find_network id
    rescue Exception
      create_network id
    end
  end

  def self.find_network id
    call :get, "/#{id}/network/#{hypervisor[:network][:id]}"
    # TODO: validate properties and state
  rescue Errors
    raise Error, 'Network not configured.'
  end

  def self.create_network id
    network = hypervisor[:network]
    call :post, "/#{id}/networks", create: '',
        name: network[:id],
        subnet: network[:address],
        dhcp: network[:dhcp],
        forward: network[:type],
        bridge_name: '',
        dns: network[:dns].join(',')
  rescue Errors
    raise Error, ''
  end

  # Storage

  def self.create_storage_if_needed id, storage
    begin
      find_storage id, storage[:id]
    rescue Exception
      create_storage id, storage[:id], storage[:path]
    end
  end

  def self.find_storage id, storage_id
    call :get, "/#{id}/storage/#{storage_id}"
  rescue Errors
    raise Error, 'Storage pools not configured'
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

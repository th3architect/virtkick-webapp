class MetaMachine < ActiveRecord::Base
  belongs_to :user


  before_destroy do
    machine.force_stop rescue nil
    machine.delete
  end

  def machine
    machine = Infra::Machine.find libvirt_machine_name
    machine.id = self.id
    machine
  end

  def self.create_machine! hostname, user_id, libvirt_hypervisor_id, libvirt_machine_name
    machine = MetaMachine.new \
        hostname: hostname,
        user_id: user_id,
        libvirt_hypervisor_id: libvirt_hypervisor_id,
        libvirt_machine_name: libvirt_machine_name
    machine.save!
    machine
  end
end

class CountDeploymentJob < BaseJob
  self.set_max_attempts 12, 2.hours

  APP_START_SUCCESS = 'app_start_success'
  SETUP_SUCCESS = 'setup_success'
  FIRST_VM_CREATE_SUCCESS = 'first_vm_create_success'
  FIRST_VM_START_SUCCESS = 'first_vm_start_success'


  def self.track event
    unless Setting.find_by_key 'tracking_' + event
      self.perform_later event
    end
  end

  def perform event
    resp = HTTParty.post 'https://stats.virtkick.io/count_deployment',
        body: {event: event}.to_json,
        headers: {'X-Techstars' => 'San Antonio'}

    unless resp.response.ok?
      raise 'HTTP request failed'
    end

    Setting.create! key: 'tracking_' + event, val: true
  end
end

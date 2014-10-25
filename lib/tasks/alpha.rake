namespace :alpha do
  desc 'Remove old virtual machines and accounts'
  task cleanup: :environment do
    User.guest.to_delete.each do |user|
      begin
        puts user.email
        user.destroy
      rescue Exception => e
        puts "#{e.class}: #{e.message}"
        Bugsnag.notify_or_ignore e
      end
    end
  end

  desc 'Delete all virtual machines from libvirt (dangerous!)'
  task disaster_cleanup: :environment do
    print "All VMs will be deleted. You've got 5 seconds to abort."
    (1..5).each do
      sleep 1
      print '.'
    end

    response = Wvm::Base.call :get, '/1/instances'
    response.instances.each do |machine|
      puts "Deleting #{machine.name}"
      Wvm::Machine.delete OpenStruct.new({hostname: machine.name})
    end
  end
end

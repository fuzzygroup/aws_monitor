namespace :aws_monitor do
  # bundle exec rake aws_monitor:ansible_hosts --trace
  task :ansible_hosts => :environment do
    
    #
    # THINGS TO CHANGE EASILY FOR ADAPTING TO YOUR PROJECT
    #
    
    # CHANGE THIS TO YOUR ANSIBLE INVENTORY FILE
    ansible_hosts_file = File.join("/Users/sjohnson/Dropbox/appdatallc/banks/", 'script/ansible/inventories/production2')
    # CHANGE THIS TO HOW MUCH TO SLEEP BETWEEN MONITOR PASSES
    sleep_time = 60 * 5  # every five minutes we will execute
    # CHANGE THIS TO YOUR SSH LOGIN
    username = "ubuntu"
    # CHANGE THIS TO THE NUMBER OF CONSECUTIVE FAILURES YOU WANT TO ALERT ON
    min_failures = 2     
    # 
    pattern = "crawler"
        
    
    #
    # END OF THINGS TO CHANGE
    #
    
    # keep track of how many runs we have made consecutively
    run_ctr = 0
    
    # run forever or until CTRL+C is presed
    while(true) do
      run_ctr = run_ctr + 1
      puts "Monitoring run: #{run_ctr}".yellow
      # see this routine to understand the format of the hosts file 
      ansible_hosts = AwsMonitor.load_ansible_hosts(ansible_hosts_file)
      failure_ctr = 0
      ansible_hosts.entries.each do |entry|
        ansible_host_struct = AwsMonitor.ini_entry_to_struct(entry)
        next unless ansible_host_struct.human_name =~ /#{pattern}/ && pattern
        session = AwsMonitor.connect_to_host(ansible_host_struct, username, sleep_time, min_failures, run_ctr)
      end
      puts "\n\n\n"
      sleep(sleep_time)
    end
  end
end
        

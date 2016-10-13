class AwsMonitor
  
  # todo need to handle NOT running correctly and assuming things are screwed up if at different location where the AWS white listed ip address isn't available
  # def self.verify_if_should_run_based_on_ip_address_and_white_list?
  # end
  
  # check current IP against white list for each machine
  def self.should_notification_work_at_all?(ip_address)
  end
  
  def self.generate_ssh_debug_command(ansible_host_struct, username, session = nil)    
    puts "Manually try: ssh -i '#{ansible_host_struct.keyfile}' #{username}@#{ansible_host_struct.host_name} -vv "
  end
  
  def self.twilio_alert(ansible_host_struct, error, delay_time = 60)
    sleep(delay_time)
    
    #
    # Todo - a Twilio alert goes here; note need to be damn sure that we're not over alerting
    #
    # delay to give time for ctrl+c
    # check log to make sure we don't over alert
  end
  
  # exception handling based on: 
  # http://blog.mirthlab.com/2012/05/25/cleanly-retrying-blocks-of-code-after-an-exception-in-ruby/ (an excellent read!; thank you)
  def self.connect_to_host(ansible_host_struct, username, sleep_time, min_failures, ctr)    
    return if ansible_host_struct.human_name =~ /ficrawlerbig/
    tries ||= 5
    session = Net::SSH.start( ansible_host_struct.host_name, username, keys: ansible_host_struct.keyfile, timeout: 3)
    
  rescue Net::SSH::ConnectionTimeout => e
    puts "Hit #{e} on #{ansible_host_struct.human_name}"
    retry unless (tries -= 1).zero?
    AwsMonitor.generate_ssh_debug_command(ansible_host_struct, username, session)
    AwsMonitor.musical_alert(ansible_host_struct, e, tries) if AwsMonitor.verify_connectivity? 
  rescue Net::SSH::Disconnect => e
    puts "Hit #{e} on #{ansible_host_struct.human_name}"
    retry unless (tries -= 1).zero?
    AwsMonitor.generate_ssh_debug_command(ansible_host_struct, username, session)
    AwsMonitor.musical_alert(ansible_host_struct, e, tries) if AwsMonitor.verify_connectivity?
  rescue StandardError => e
    puts "Hit #{e} on #{ansible_host_struct.human_name}"
    retry unless (tries -= 1).zero?
    AwsMonitor.generate_ssh_debug_command(ansible_host_struct, username, session)
    AwsMonitor.musical_alert(ansible_host_struct, e, tries) if AwsMonitor.verify_connectivity?
  else
    puts "Success!  The box #{ansible_host_struct.human_name} is still alive and has been for: #{ctr*sleep_time} seconds!!!".green
    session.close
  end 
  
  def self.verify_connectivity?
    require 'net/ping'
    p1 = Net::Ping::External.new('8.8.8.8')
    # try three times to verify external connectivity
    return true if p1.ping?
    sleep(0.25)
    return true if p1.ping?
    sleep(0.25)
    return true if p1.ping?    
    return false
  end
  
  def self.musical_alert(ansible_host, error, tries)
    songs = ["/Users/sjohnson/Dropbox/music_alerts/success_dont_worry_be_happy.mp3", "/Users/sjohnson/Dropbox/music_alerts/qr_we_are_not_going_to_take_it.mp3", "/Users/sjohnson/Dropbox/music_alerts/white_wedding.mp3"]
    song = songs.sample
    `afplay -v 5 #{song}`
    #puts "failure @ #{ansible_host.host_name}"
    raise "ERROR on aws box: \n#{error}\nssh #{ansible_host.human_name}"
  end
  
  def self.load_ansible_hosts(ansible_hosts_file)
    require 'inifile'
    IniFile.load(ansible_hosts_file)    
  end
  
  def self.ini_entry_to_struct(entry)
    section = entry[0]
    human_name_and_ssh_host_key = entry[1].gsub(/ +/,' ')
    host_name_and_key_file = entry[2].gsub(/ +/,' ')
    human_name_parts = human_name_and_ssh_host_key.split(" ")
    host_name_and_keyfile_parts = host_name_and_key_file.split(" ")
    return OpenStruct.new(:section => section, :human_name => human_name_parts[0], :host_name => host_name_and_keyfile_parts[0], :keyfile => host_name_and_keyfile_parts[1].split("=").second)
  end
    
end

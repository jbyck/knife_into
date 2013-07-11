class Into < Chef::Knife
  
  # Knife plugin to SSH into Chef nodes via node name
  # Expects key authentication configured in knife.rb
  # Only tested with AWS
  
  banner "knife into NODE_NAME (options)"
    
  deps do
    require 'chef/node'
  end
  
  option :ssh_user,
    short: '-x',
    long:  '--ssh-user',
    description: "SSH user",
    proc: Proc.new { |k| Chef::Config[:knife][:ssh_user] == k }
    
  option :identity_file,
    short: '-i',
    long: '--identity-file',
    description: 'Identify file to use',
    proc: Proc.new { |k| Chef::Config[:knife][:identify_file] == k }
  
  def run
    
    unless name_args.size >= 1
      ui.fatal "Node name required"
      show_usage
      exit 1
    end
    
    node_name = name_args.first    
    ui.msg "Attempting to load #{node_name}" if verbose?
    node = Chef::Node.load(node_name)
    
    unless node.attribute?(:cloud) and node.cloud.attribute?(:public_ipv4)
      ui.fatal "Cannot extract remote data from node #{node_name}"
      exit!
    end
    
    public_ip = node.cloud.public_ipv4
    ui.msg "Connecting to #{node_name} with #{public_ip} using #{config[:identity_file]} for #{config[:ssh_user]}" if verbose?
        
    exec("ssh #{config[:ssh_user]}@#{public_ip} -i #{config[:identity_file]}")
    
  end 
  
  def verbose?
    config[:verbosity] > 0
  end
  
end
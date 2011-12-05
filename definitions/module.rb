define :nginx_module, :action => :create, :template => nil, :auto => true do
  include_recipe "nginx"

  suffix = params[:auto] ? "conf" : "include"

  template "/etc/nginx/modules/#{params[:name]}.#{suffix}" do
    action params[:action]
    source params[:template]
    owner "root"
    group "root"
    mode "0644"
    variables :params => params
    notifies :reload, resources(:service => "nginx")
  end
end

define :nginx_build_with, :modules => [] do  
  begin
    pu = resources(:portage_package_use => "www-servers/nginx")
  rescue Chef::Exceptions::ResourceNotFound
    pu =
      portage_package_use "www-servers/nginx" do
        use params[:modules]
      end
  end
  params[:modules].each do |d|
    Chef::Log.debug "nginx_build_with -> #{d}"
    # skip if allready included or negative
    next if pu.use.include?(d) or d =~ /^-/
    pu.use.delete_if{|e|e=~/^-#{d}$/}
    Chef::Log.debug "nginx_build_with + #{d}"
    pu.use << d
    pu.notifies :reinstall, resources(:package => 'www-servers/nginx'), :immediately
  end
  node[:nginx][:use_flags] = pu.use
end

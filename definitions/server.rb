define :nginx_server, :action => :create do
  include_recipe "nginx"

  template "/etc/nginx/servers/#{params[:name]}.conf" do
    action params[:action]
    source params[:template]
    owner "root"
    group "root"
    mode "0644"
    variables :params => params
    notifies :reload, resources(:service => "nginx")
    cookbook params[:cookbook] if params[:cookbook]
  end
end

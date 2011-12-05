include_recipe "syslog"

nginx_build_with do
  modules %w(
    -nginx_modules_http_browser
    -nginx_modules_http_empty_gif
    -nginx_modules_http_geo
    -nginx_modules_http_memcached
    -nginx_modules_http_ssi
    -nginx_modules_http_userid
    aio
    nginx_modules_http_empty_gif
    nginx_modules_http_realip
    nginx_modules_http_stub_status
    nginx_modules_http_x_rid_header
  )
end

portage_package_keywords "=www-servers/nginx-1.0.8"

group "nginx" do
  gid 82
  append true
end

user "nginx" do
  uid 82
  gid 82
  home "/dev/null"
  shell "/sbin/nologin"
end

package "www-servers/nginx" do
  version '1.0.8'
end

service "nginx" do
  action [:enable, :start]
  supports [:reload]
end

%w(
  /etc/nginx
  /etc/nginx/modules
  /etc/nginx/servers
  /etc/ssl/nginx
).each do |d|
  directory d do
    owner "root"
    group "root"
    mode "0755"
  end
end

directory "/var/cache/nginx" do
  owner "nginx"
  group "nginx"
  mode "0755"
end

template "/etc/nginx/nginx.conf" do
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, "service[nginx]"
end

nginx_module "fastcgi" do
  template "fastcgi.conf.erb"
end

link "/etc/nginx/fastcgi.conf" do
  to "/etc/nginx/modules/fastcgi.conf"
end

file "/etc/nginx/fastcgi_params" do
  action :delete
end

nginx_server "status" do
  template "status.conf"
end

syslog_config "90-nginx" do
  template "syslog.conf"
end

cookbook_file "/etc/logrotate.d/nginx" do
  source "logrotate.conf"
  owner "root"
  group "root"
  mode "0644"
end

monit_config "nginx" do
  source "monit.erb"
  cookbook "nginx"
end

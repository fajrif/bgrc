# config/unicorn.rb
root = "/home/deployer/preproduction/bgrc"
working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

listen "#{root}/tmp/sockets/unicorn.bgrc.sock", backlog: 64
worker_processes 4
# Checkout calls the payment gateway and sends mail inside the request.
timeout 60
preload_app true

# A re-exec'd master (USR2) must find the same Gemfile as the one that started it.
before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = "#{root}/Gemfile"
end

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord::Base)
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
end

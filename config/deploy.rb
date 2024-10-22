lock '3.11.0'

set :application, 'psap'
set :repo_url, 'git@github.com:PresConsUIUC/PSAP.git'
set :user, 'psap'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
set :branch, 'master'

set :home, '/home/psap'
set :bin, "#{fetch(:home)}/bin"

# Default deploy_to directory is /var/www/my_app
set :deploy_to, "#{fetch(:home)}/psap-capistrano"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}
set :linked_files, %w{config/database.yml config/psap.yml config/secrets.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  before :publishing, :stop_passenger

  task :stop_passenger do
    on roles(:app), in: :sequence, wait: 5 do
      puts "Use `sudo systemd stop psap` to stop the application."
      #execute "#{fetch(:bin)}/stop-rails"
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      #execute :touch, release_path.join('tmp/restart.txt')
      #execute "#{fetch(:bin)}/start-rails"
      puts "Use `sudo systemd start psap` to stop the application."
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

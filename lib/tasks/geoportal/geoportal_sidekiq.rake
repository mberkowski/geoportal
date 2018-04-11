# lib/tasks/migrate/users.rake
require 'sidekiq/api'

namespace :geoportal do
  desc 'Stop sidekiq'
  task sidekiq_stop: :environment do
    sh "sudo systemctl stop sidekiq.service"
    sleep(5)
    sh "sudo systemctl status sidekiq.service"
  end

  task sidekiq_start: :environment do
    sh "sudo systemctl start sidekiq.service"
    sleep(5)
    sh "sudo systemctl status sidekiq.service"
  end

  desc 'Check sidekiq stats'
  task sidekiq_stats: :environment do
    # Check stats
    stats = Sidekiq::Stats.new
    puts stats.inspect
  end

  desc 'Clear sidekiq queues'
  task sidekiq_clear_queues: :environment do
    Sidekiq::RetrySet.new.clear
    Sidekiq::ScheduledSet.new.clear
    Sidekiq::Stats.new.reset
    Sidekiq::DeadSet.new.clear

    stats = Sidekiq::Stats.new
    stats.queues
    stats.queue.count
    stats.queue.clear
    
    puts stats.inspect
  end
end

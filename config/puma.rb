threads_count = ENV.fetch('RAILS_MAX_THREADS') { 1 }.to_i
threads threads_count, threads_count

environment ENV.fetch('RAILS_ENV') { 'development' }

port ENV.fetch('PORT') { 3000 }

plugin :tmp_restart

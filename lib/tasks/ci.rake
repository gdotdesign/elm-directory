task :ci do
  # sh 'rspec'
  sh 'rubocop'
  sh 'haml-lint'
  sh 'scss-lint'
end

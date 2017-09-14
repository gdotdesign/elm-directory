Octokit.configure do |c|
  c.client_id = ENV['GITHUB_CLIENT_ID']
  c.client_secret = ENV['GITHUB_CLIENT_SECRET']
end

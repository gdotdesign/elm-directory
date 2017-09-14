require 'sidekiq/web'

Rails.application.routes.draw do
  root 'packages#landing'

  mount Sidekiq::Web => '/sidekiq'

  get '/recently-updated',
      to: 'packages#recent',
      as: :recently_updated

  get '/native-packages',
      to: 'packages#native',
      as: :native_packages

  get '/effect-manager-packages',
      to: 'packages#effect_managers',
      as: :effect_manager_packages

  get '/packages',
      to: 'packages#index',
      as: :packages

  get '/package/:author',
      to: 'packages#by_author',
      as: :repo_author

  get '/package/:author/:repo',
      to: 'versions#show',
      constraints: {
        repo:  %r{[^/]+}
      },
      as: :repo_root

  get '/package/:author/:repo/:version',
      to: 'versions#version',
      constraints: { version: /\d+\.\d+\.\d+/ },
      as: :repo_version

  get '/package/:author/:repo/:version/:module',
      to: 'versions#module',
      constraints: {
        version: /\d+\.\d+\.\d+/,
        module: /.*/
      },
      as: :repo_module
end

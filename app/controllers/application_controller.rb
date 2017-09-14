class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_breadcrumbs

  def set_breadcrumbs
    add_breadcrumb 'Home', root_path

    if params[:author]
      add_breadcrumb params[:author],
                     repo_author_path(params[:author])
    end

    if params[:author] && params[:repo]
      add_breadcrumb params[:repo],
                     repo_root_path(params[:author], params[:repo])
    end

    if params[:author] && params[:repo] && params[:version]
      add_breadcrumb params[:version],
                     repo_version_path(params[:author],
                                       params[:repo],
                                       params[:version])
    end

    if params[:author] && params[:repo] && params[:version] && params[:module]
      add_breadcrumb params[:module],
                     repo_module_path(params[:author],
                                      params[:repo],
                                      params[:version],
                                      params[:module])
    end
  end
end

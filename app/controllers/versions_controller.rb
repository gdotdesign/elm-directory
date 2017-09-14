class VersionsController < ApplicationController
  before_action :find_version, only: [:version, :module]
  before_action :set_title

  def module
    @module = params[:module]
    render :show
  rescue StandardError
    redirect_to repo_version_path(params[:author],
                                  params[:repo],
                                  params[:version])
  end

  def show
    @version =
      Package
      .find_by_repository("#{params[:author]}/#{params[:repo]}")
      .latest_version
  rescue StandardError
    redirect_to repo_author_path(params[:author])
  end

  def version
    render :show
  rescue StandardError
    redirect_to repo_root_path(params[:author], params[:repo])
  end

  def set_title
    title_parts = [
      params[:author],
      params[:repo],
      params[:version],
      params[:module]
    ]

    set_meta_tags(title: title_parts.compact.join(' - '))
  end

  def find_version
    @version =
      Package
      .find_by_repository("#{params[:author]}/#{params[:repo]}")
      .versions
      .find_by_version params[:version]
  rescue StandardError
    redirect_to repo_root_path(params[:author], params[:repo])
  end
end

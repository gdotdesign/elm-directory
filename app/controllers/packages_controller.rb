class PackagesController < ApplicationController
  def landing
    set_meta_tags title: 'Find and read documentation of Elm packages.'

    if params[:search]
      @packages =
        Package
        .search
        .where(
          "package_json->>'summary' ILIKE ? OR repository ILIKE ?",
          "%#{params[:search]}%",
          "%#{params[:search]}%")

      render :search
    else
      @packages =
        Package
        .includes(:latest_version)
        .visible
        .order(stars: :desc)
        .limit(30)

      @recent =
        Package
        .includes(:latest_version)
        .recent
        .limit(30)
    end
  end

  def recent
    set_meta_tags title: 'Recently Updated Packages'

    @packages =
      Package
      .includes(:latest_version)
      .recent
      .limit(30)
  end

  def by_author
    set_meta_tags title: "Packages by #{params[:author]}"

    @packages =
      Package
      .includes(:latest_version)
      .visible
      .where('repository ILIKE ?', "#{params[:author]}%")
  end

  def native
    set_meta_tags title: 'Native Packages'

    @packages = Package.native
  end

  def effect_managers
    set_meta_tags title: 'Effect Manager Packages'

    @packages = Package.effect_manager
  end

  def index
    set_meta_tags title: 'All packages'

    @packages =
      Package
      .visible
      .includes(:latest_version)
  end
end

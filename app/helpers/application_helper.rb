module ApplicationHelper
  def search_highlighted(value)
    if params[:search]
      value.gsub(Regexp.new(params[:search], 'i'), '<b>\0</b>').html_safe
    else
      value
    end
  end
end

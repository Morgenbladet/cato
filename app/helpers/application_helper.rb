module ApplicationHelper
  def auto_link(text)
    Rinku.auto_link(text).html_safe
  end
end

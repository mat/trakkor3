# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
 def html_title(str="")
    unless str.blank?
      content_for :html_title do
       "&mdash; #{h str}".html_safe
      end
    end
  end  

end

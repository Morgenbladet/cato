module NominationsHelper
  def personalia(nomination)
    [
      case(nomination.gender)
      when "Male" then "♂"
      when "Female" then "♀"
      else nil
      end,
      nomination.age ? "#{nomination.age} år" : nil,
      nomination.branch.blank? ? nil : nomination.branch
    ].compact.join(", ")
  end

  def sorting_link(name, key, default_dir='asc')
    if @sort_params && @sort_params.split[0] == key
      current_sortdir = @sort_params.split[1]
      dir = (current_sortdir == 'desc') ? 'asc' : 'desc'
    else
      dir = default_dir
    end

    link_to name, params.merge({sort: "#{key} #{dir}"}), class: "sortable #{current_sortdir}"
  end

  def merge_reasons(nomination)
    nomination.reasons.map do |r|
      simple_format(r.reason, {}, wrapper_tag: 'blockquote') +
        content_tag(:p, "– #{r.nominator}", class: 'nominator')
    end.join.html_safe
  end

end

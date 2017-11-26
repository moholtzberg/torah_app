module ApplicationHelper
  def days
    [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]
  end

  def errors_for(object)
    if object.errors.any?
        content_tag(:div, class: "panel panel-danger") do
            concat(content_tag(:div, class: "panel-heading") do
                concat(content_tag(:h4, class: "panel-title") do
                    concat "#{pluralize(object.errors.count, "error")} prohibited this #{object.class.name.downcase} from being saved:"
                end)
            end)
            concat(content_tag(:div, class: "panel-body") do
                concat(content_tag(:ul) do
                    object.errors.full_messages.each do |msg|
                        concat content_tag(:li, msg)
                    end
                end)
            end)
        end
    end
  end

  def flash_for flash
    flash.map do |key, value|
      case key
        when "danger"
          "<div class='alert alert-danger'>#{value}</div>"
        when "alert"
          "<div class='alert alert-warning'>#{value}</div>"
        when "success"
          "<div class='alert alert-success'>#{value}</div>"
        when "warning"
          "<div class='alert alert-warning'>#{value}</div>"
        when "info"
          "<div class='alert alert-info'>#{value}</div>"
        else
          "<div class='alert alert-warning'>#{value}</div>"
        end
    end.join(" ").html_safe
  end
end

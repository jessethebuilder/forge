module ApplicationHelper
  def current_account
    @current_account
  end

  def show_errors(record)
    render partial: 'helpers/errors', locals: {record: record}
  end

  def activator(record)
    render partial: 'helpers/activator', locals: {record: record}
  end

  def full_width_container
    content_tag :div, class: 'container' do
      content_tag :div, class: 'row' do
        content_tag :div, class: 'col-sm-12' do
          yield
        end
      end
    end
  end

  def checkbox_group(form, attribute)
    content_tag :div, class: 'form-group' do
      content_tag :div, class: 'form-check' do
        form.check_box attribute, class: 'form-check-input'
        form.label attribute, class: 'form-check-label'
      end
    end
  end
end

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
        content_tag :div, class: 'container-sm-12' do
          yield
        end
      end
    end
  end
end

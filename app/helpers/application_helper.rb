module ApplicationHelper
  def current_account
    @current_account
  end

  def show_errors(record)
    render partial: 'layouts/partials/errors', locals: {record: record}
  end
end

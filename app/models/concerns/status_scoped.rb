module StatusScoped
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where(active: true).where(archived: false) }
    scope :inactive, -> { where(active: false).where(archived: false) }
    scope :archived, -> { where(archived: true) }
  end
end

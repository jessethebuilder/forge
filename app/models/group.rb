class Group < ApplicationRecord
  belongs_to :account
  belongs_to :menu, optional: true

  has_many :products

  validates :name, presence: true

  default_scope -> { order(:order) }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  validate :product_belongs_to_menu

  private

  def product_belongs_to_menu
    return unless menu
    errors.add(:menu, 'does not belong to this account') unless account == menu.account
  end
end

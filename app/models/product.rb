class Product < ApplicationRecord
  belongs_to :account
  belongs_to :menu, optional: true
  belongs_to :group, optional: true

  has_many :order_items

  validates :price, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :name, presence: true

  validate :product_belongs_to_group
  validate :product_belongs_to_menu

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  default_scope -> { order(:order) }

  def product_belongs_to_group
    return unless group
    errors.add(:group, 'does not belong to this account') unless account == group.account
  end

  def product_belongs_to_menu
    return unless menu
    errors.add(:menu, 'does not belong to this account') unless account == menu.account
  end
end

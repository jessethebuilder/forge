class Product < ApplicationRecord
  include StatusScoped

  belongs_to :account
  belongs_to :menu, optional: true
  belongs_to :group, optional: true

  has_many :order_items

  validates :price, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :name, presence: true

  validate :product_belongs_to_group
  validate :product_belongs_to_menu

  def group_name
    group&.name
  end

  def menu_name
    menu&.name
  end

  def exists_on_order?
    self.order_items.first ? true : false
  end

  default_scope -> { order(:order) }

  before_destroy :archive_if_exists_on_order

  private

  def archive_if_exists_on_order
    if exists_on_order?
      self.update(archived: true)
      throw :abort
    end
  end

  def product_belongs_to_group
    return unless group
    errors.add(:group, 'does not belong to this account') unless account == group.account
  end

  def product_belongs_to_menu
    return unless menu
    errors.add(:menu, 'does not belong to this account') unless account == menu.account
  end
end

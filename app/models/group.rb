class Group < ApplicationRecord
  include StatusScoped

  belongs_to :account
  belongs_to :menu, optional: true

  has_many :products

  validates :name, presence: true

  default_scope -> { order(:order) }

  validate :product_belongs_to_menu

  def menu_name
    menu&.name
  end

  private

  def product_belongs_to_menu
    return unless menu
    errors.add(:menu, 'does not belong to this account') unless account == menu.account
  end
end

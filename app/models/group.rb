class Group < ApplicationRecord
  belongs_to :account
  belongs_to :menu, optional: true

  has_many :products

  validates :name, presence: true

  default_scope -> { order(:order) }
  
  scope :active, -> { where(active: true) }
end

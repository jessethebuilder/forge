class Credential < ApplicationRecord
  belongs_to :account

  validates :username, presence: true, uniqueness: true
  validates :token, presence: true
end

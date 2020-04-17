class Credential < ApplicationRecord
  belongs_to :account
  belongs_to :user, required: false

  validates :username, presence: true, uniqueness: true
  validates :token, presence: true

  before_validation :generate_token, only: [:create]

  def generate_token
    loop do
      self.token = SecureRandom.base64.tr('+/=', 'Qrt')
      break unless Credential.exists?(token: token)
    end
  end
end

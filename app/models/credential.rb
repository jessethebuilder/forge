class Credential < ApplicationRecord
  belongs_to :account

  validates :token, presence: true, uniqueness: true

  before_validation :generate_token, on: [:create]

  def generate_token
    loop do
      self.token = SecureRandom.base64.tr('+/=', 'Qrt')
      break unless Credential.exists?(token: token)
    end
  end
end

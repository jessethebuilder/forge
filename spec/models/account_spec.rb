describe Account, type: :model do
  before do
    @account = build(:account)
  end

  describe 'Validations' do
    it{ should validate_presence_of :email }
    it{ should validate_uniqueness_of :email }
    it{ should validate_presence_of :name }
  end # Validations

  describe 'Associations' do
    it{ should have_many :menus }
    it{ should have_many :products }
    it{ should have_many :groups }
    it{ should have_many :orders }
    it{ should have_many :customers }
    it{ should have_many :credentials }
  end # Associations

  describe 'Attributes' do
  end # Attributes

  describe 'Behaviors' do
  end # Behaviors

  describe 'Methods' do
  end # Methods

  describe 'Class Methods' do
    before do
      @account.save!
    end
  end # Class Methods
end

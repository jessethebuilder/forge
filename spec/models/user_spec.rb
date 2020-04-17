describe User, type: :model do
  before do
    @user = build(:user)
  end

  describe 'Validations' do
    specify{ association_must_exist(@user, :account) }
  end # Validations

  describe 'Associations' do
    it{ should belong_to :account }
    it{ should have_one :credential }
  end # Associations

  describe 'Attributes' do
  end # Attributes

  describe 'Behaviors' do
  end # Behaviors

  describe 'Methods' do
  end # Methods

  describe 'Class Methods' do
    before do
      @user.save!
    end
  end # Class Methods
end

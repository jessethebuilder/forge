describe Credential, type: :model do
  before do
    @credential = build(:credential)
  end

  describe 'Validations' do
    it{ should validate_presence_of :username }
    it{ should validate_uniqueness_of :username }

    specify{ association_must_exist(@credential, :account) }
  end # Validations

  describe 'Associations' do
    it{ should belong_to :account }
    it{ should belong_to :user }
  end # Associations

  describe 'Attributes' do
  end # Attributes

  describe 'Behaviors' do
    it 'should generate a token on creation' do
      @credential.token = nil
      @credential.save!
      @credential.token.should_not == nil
    end
  end # Behaviors

  describe 'Methods' do
  end # Methods

  describe 'Class Methods' do
    before do
      @credential.save!
    end
  end # Class Methods
end

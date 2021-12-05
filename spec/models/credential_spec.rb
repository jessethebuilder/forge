describe Credential, type: :model do
  before do
    @credential = build(:credential)
  end

  it 'should be valid' do
    @credential.valid?.should == true
  end

  describe 'Validations' do
  end # Validations

  describe 'Associations' do
    it{ should belong_to(:account).required }
  end # Associations

  describe 'Attributes' do
  end # Attributes

  describe 'Behaviors' do
    it 'should generate a token on creation' do
      @credential.token = nil
      @credential.save!
      @credential.token.should_not == nil
    end

    it 'should not update token on Update' do
      @credential.save!
      token = @credential.token
      @credential.save!
      @credential.token.should == token
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

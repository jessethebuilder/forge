describe Account, type: :model do
  before do
    @account = build(:account)
  end

  describe 'Validations' do
    it{ should validate_presence_of :schema }
    it{ should validate_inclusion_of(:schema).in_array(Account::SCHEMAS) }
  end # Validations

  describe 'Associations' do
    it{ should have_many :menus }
    it{ should have_many :products }
    it{ should have_many :groups }
    it{ should have_many :orders }
    it{ should have_many :customers }
    it{ should have_many :credentials }
    it{ should have_many :users }
  end # Associations

  describe 'Attributes' do
    specify ':data defaults to and empty Hash' do
      @account.data.should == {}
    end

    specify ':schema defaults to "menu"' do
      @account.schema.should == 'menu'
    end
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

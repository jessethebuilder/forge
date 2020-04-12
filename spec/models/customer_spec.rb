describe Customer, type: :model do
  before do
    @customer = build(:customer)
  end

  describe 'Validations' do
    specify{ association_must_exist(@customer, :account) }
  end # Validations

  describe 'Associations' do
    it{ should belong_to :account }

    it{ should have_many :orders }
  end # Associations

  describe 'Attributes' do
    specify ':data defaults to and empty Hash' do
      @customer.data.should == {}
    end
  end # Attributes

  describe 'Behaviors' do
  end # Behaviors

  describe 'Methods' do
  end # Methods

  describe 'Class Methods' do
    before do
      @customer.save!
    end
  end # Class Methods
end

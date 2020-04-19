describe Product, type: :model do
  before do
    @product = build(:product)
  end

  describe 'Validations' do
    it{ should validate_presence_of(:name) }
    it{ should validate_presence_of(:price) }
    it{ should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }

    specify{ association_must_exist(@product, :account) }

    specify '@product.group must belong to account' do
      @product.group = create(:group)
      @product.valid?.should == false
      @product.errors[:group].should == ['does not belong to this account']
    end

    specify '@product.menu must belong to accont' do
      @product.menu = create(:menu)
      @product.valid?.should == false
      @product.errors[:menu].should == ['does not belong to this account']
    end
  end # Validations

  describe 'Associations' do
    it{ should belong_to :account }
    it{ should belong_to :group }
    it{ should belong_to :menu }

    it{ have_many :order_items }
  end # Associations

  describe 'Attributes' do
    specify ':active defaults to true' do
      @product.active.should == true
    end

    specify ':data defaults to and empty Hash' do
      @product.data.should == {}
    end
  end # Attributes

  describe 'Behaviors' do
  end # Behaviors

  describe 'Methods' do
  end # Methods

  describe 'Class Methods' do
    before do
      @product.save!
    end
  end # Class Methods
end

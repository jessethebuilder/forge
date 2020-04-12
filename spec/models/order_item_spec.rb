describe OrderItem, type: :model do
  before do
    @order_item = build(:order_item)
    @product = @order_item.product
  end

  describe 'Validations' do
    it{ should validate_presence_of(:amount) }
    it{ should validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }

    specify{ association_must_exist(@order_item, :order) }
    specify{ association_must_exist(@order_item, :product) }

    it 'should validate that product is available' do
      @order_item.product.update(active: false)
      @order_item.valid?.should == false
      @order_item.errors[:product].should == ["#{@product.id} is no longer available"]
    end

    it 'should validate that product is available' do
      @order_item.product.update(price: @order_item.product.price + 14)
      @order_item.valid?.should == false
      @order_item.errors[:product].should == ["#{@product.id} price has changed"]
    end
  end # Validations

  describe 'Associations' do
    it{ should belong_to :order }
    it{ should belong_to :product }
  end # Associations

  describe 'Attributes' do
  end # Attributes

  describe 'Behaviors' do
  end # Behaviors

  describe 'Methods' do
  end # Methods

  describe 'Class Methods' do
    before do
      @order_item.save!
    end
  end # Class Methods
end

describe Order, type: :model do
  before do
    @order = build(:order)
  end

  describe 'Validations' do
    specify{ association_must_exist(@order, :account) }
  end # Validations

  describe 'Associations' do
    it{ should belong_to :account }
    it{ should belong_to :menu }
    it{ should belong_to :customer }

    it{ should have_many :order_items }
  end # Associations

  describe 'Attributes' do
  end # Attributes

  describe 'Behaviors' do
  end # Behaviors

  describe 'Methods' do
    describe '#total' do
      it 'should return the total of all order_items' do
        product = create(:product, price: 15.0)
        @order.order_items << [
          create(:order_item, product: product),
          create(:order_item, product: product)
        ]
        @order.total.should == 30
      end
    end
  end # Methods

  describe 'Class Methods' do
    before do
      @order.save!
    end
  end # Class Methods
end

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

    it{ should have_many :transactions }
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
          build(:order_item, product: product),
          build(:order_item, product: product)
        ]
        @order.total.should == 30
      end
    end

    describe '#refund_total' do
      it 'should return the total of all refunds' do
        product = create(:product, price: 30.0)
        @order.order_items << build(:order_item, product: product)

        create(:charge, order: @order)

        create(:refund, order: @order, amount: -10)
        create(:refund, order: @order, amount: -10)

        @order.refund_total.should == -20
      end
    end
  end # Methods

  describe 'Class Methods' do
    before do
      @order.save!
    end
  end # Class Methods
end

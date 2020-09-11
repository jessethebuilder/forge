describe Order, type: :model do
  before do
    @order = build(:order)
    allow(NewOrderNotificationJob).to receive(:perform_async)
  end

  describe 'Validations' do
    specify{ association_must_exist(@order, :account) }
  end # Validations

  describe 'Associations' do
    it{ should belong_to :account }
    it{ should belong_to(:menu).required(false) }
    it{ should belong_to(:customer).required(false) }

    it{ should have_many :order_items }

    it{ should have_many :transactions }
  end # Associations

  describe 'Attributes' do
    specify ':active defaults to true' do
      @order.active.should == true
    end

    specify ':seen defaults to false' do
      @order.seen.should == false
    end
  end # Attributes

  describe 'Behaviors' do
  end # Behaviors

  describe 'Methods' do
    describe 'Money Methods' do
      before do
        @product = create(:product, price: 15.0)
        @order.order_items << [
          build(:order_item, product: @product),
          build(:order_item, product: @product)
        ]
      end

      describe '#subtotal' do
        it 'should return the total of all order_items' do
          @order.subtotal.should == 30
        end
      end

      describe '#total' do
        it 'should return sub_total + tax + tip' do
          @order.tax = 10
          @order.tip = 10
          @order.total.should == 50
        end
      end

      describe '#refund_total' do
        it 'should return the total of all refunds' do
          create(:charge, order: @order) # The first Transaction, must be a Charge!
          create(:refund, order: @order, amount: -10)
          create(:refund, order: @order, amount: -10)
          @order.refund_total.should == -20
        end
      end
    end

    describe '#complete?' do
      it 'should return true if a positive transation exists matching :total' do
        @order.save!
        create(:order_item, order: @order)
        expect{ create(:transaction, order: @order, amount: @order.total) }
              .to change{ @order.reload.complete? }.from(false).to(true)
      end
    end
  end # Methods

  describe 'Class Methods' do
    before do
      @order.save!
    end
  end # Class Methods
end

describe Order, type: :model do
  before do
    stub_stripe_client

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

  describe 'Methods' do
    describe 'Money Methods' do
      before do
        @product = create(:product, price: 1500)
        @order.order_items << [
          build(:order_item, product: @product),
          build(:order_item, product: @product)
        ]
      end

      describe '#subtotal' do
        it 'should return the total of all order_items' do
          @order.subtotal.should == 3000
        end
      end

      describe '#total' do
        it 'should return sub_total + tax + tip' do
          @order.tax = 100
          @order.tip = 100
          @order.total.should == 3200
        end
      end

      describe '#refund_total' do
        it 'should return the total of all refunds' do
          create(:charge, order: @order) # The first Transaction, must be a Charge!
          create(:refund, order: @order, amount: -50)
          create(:refund, order: @order, amount: -50)
          @order.refund_total.should == -100
        end
      end
    end # Money Methods

    describe '#funded?' do
      it 'should return true if a positive transation exists matching :total' do
        @order.save!
        create(:order_item, order: @order)
        expect{ create(:transaction, order: @order, amount: @order.total) }
              .to change{ @order.reload.funded? }.from(false).to(true)
      end
    end

    describe '#charge?' do

    end

    describe '#refund?' do

    end

    describe '#seen?' do
      it 'should return true of there is a :seen_at' do
        @order.seen_at = Time.now
        @order.seen?.should == true
      end

      it 'should return false if :seen_at is nil (default)' do
        @order.seen?.should == false
      end
    end # seen?

    describe '#see' do
      before do
        @time = Time.now
        allow(Time).to receive(:now).and_return(@time)
      end

      it 'should set seen_at to Time.now' do
        expect{ @order.see }.to change{ @order.seen_at }.from(nil).to(@time)
      end
    end # see

    describe '#unsee' do
      before do
        @time = Time.now
        allow(Time).to receive(:now).and_return(@time)
        @order.update(seen_at: @time)
      end

      it 'should set seen_at to nil' do
        expect{ @order.unsee }.to change{ @order.seen_at }.from(@time).to(nil)
      end
    end # unsee

    describe '#see=' do
      before do
        @time = Time.now
        allow(Time).to receive(:now).and_return(@time)
      end

      it 'should set seen_at to nil if false' do
        @order.update(seen_at: @time)
        expect{ @order.see = false }.to change{ @order.seen_at }.from(@time).to(nil)
      end
    end # see=
  end # Methods

  describe 'Class Methods' do
    before do
      @order.save!
    end
  end # Class Methods
end

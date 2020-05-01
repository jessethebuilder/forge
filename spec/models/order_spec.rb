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
    specify ':active defaults to true' do
      @order.active.should == true
    end

    specify ':seen defaults to false' do
      @order.seen.should == false
    end
  end # Attributes

  describe 'Behaviors' do
    describe 'Creation' do
      before do
        allow(ActionCable.server).to receive(:broadcast)
      end

      it 'should Broadcast on creation' do
        @order.save!

        expect(ActionCable.server).to have_received(:broadcast).with(
          "orders_for_account_#{@order.account.id}",
          {
            action: 'new_order',
            data: {
              order_id: @order.reload.id
            }
          }
        )
      end

      it 'should not Broadcast on update' do
        @order.save!
        expect(ActionCable.server).not_to receive(:broadcast)
        @order.save!
      end
    end

      #
      # ActionCable.server.broadcast(
      #   "orders_for_account_#{account.id}",
      #   {
      #     action: 'new_order',
      #     data: {
      #       order_id: self.id
      #     }
      #   }
      # )
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

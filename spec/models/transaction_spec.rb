describe Transaction, type: :model do
  before do
    @order = create(:order, :with_items)
    @charge = build(:charge, order: @order)
  end

  describe 'Validations' do
    it{ should validate_presence_of :amount }
    it{ should validate_numericality_of :amount }

    describe 'Charge' do
      it 'Must be the first Transaction on Order' do
        @charge.save!

        refund = create(:refund, order: @order)

        new_charge = build(:charge, order: @order)
        new_charge.valid?.should == false
        new_charge.errors[:charge].should == ['must be the first Transaction on an Order']
      end

      it 'must be in the amount of the order #total' do
        @charge.amount = @order.total + 1
        @charge.valid?.should == false
        @charge.errors[:amount].should == ['must equal Order total']
      end
    end # Positive Transactions

    describe 'Refund' do
      it 'Must NOT be the first Transaction on Order' do
        @charge.amount = -(@order.total - 1)
        @charge.valid?.should == false
        @charge.errors[:refund].should == ['cannot be the first Transaction on an Order']
      end

      context 'After a Charge' do
        before do
          @charge.save!
        end

        it 'must be less than :amount' do
          refund = build(:refund, order: @order)
          refund.amount = -(@order.total) -1
          refund.valid?.should == false
          refund.errors[:amount].should == ['cannot be less than Order total']
        end

        it 'must be less than the amount of ALL negative Refunds' do
          first_refund = build(:refund, order: @order)
          first_refund.amount = -@order.total
          first_refund.save!

          second_refund = build(:refund, order: @order)
          second_refund.amount = -0.01

          second_refund.valid?.should == false
          second_refund.errors[:amount].should == ['cannot be less than Order total']
        end
      end
    end
  end # Validations

  describe 'Associations' do
    it{ should belong_to :order }
  end # Associations

  describe 'Attributes' do
  end # Attributes

  describe 'Behaviors' do
  end # Behaviors

  describe 'Methods' do
  end # Methods

  describe 'Class Methods' do
    before do
      @charge.save!
      @refund = create(:refund, order: @order)
    end

    describe 'Scopes' do
      describe '#charges' do
        it 'should only return Refunds' do
          Transaction.charges.should == [@charge]
        end
      end

      describe '#refunds' do
        it 'should only return Refunds' do
          Transaction.refunds.should == [@refund]
        end
      end
    end
  end # Class Methods
end

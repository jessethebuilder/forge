describe Transaction, type: :model do
  before do
    stub_stripe_client

    @order = create(:order, :with_items)
    @account = @order.account
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

      describe 'Payment Method' do
        it 'should return an error if no token (or card info) is provided' do
          @charge.stripe_token = nil
          @charge.valid?.should == false
          @charge.errors[:charge].should == ['requires a valid payment method']
        end
      end # Payment Method

      context 'With a Customer on the Order' do
        before do
          @customer = create(:customer, account: @account, orders: [@order])
        end

        it 'should call StripeClient to create a Customer' do
          expect_any_instance_of(StripeClient).to receive(:create_customer)
          @charge.save!
        end

        it 'should update Customer with stripe_id' do
          customer_id = Faker::Lorem.word
          allow_any_instance_of(StripeClient)
              .to receive(:create_customer)
              .and_return(double(id: customer_id))
          expect{ @charge.save! }.to change{ @customer.reload.stripe_id }
              .from(nil).to(customer_id)
        end

        it 'should NOT create a Stripe Customer if Custmer has a Stripe ID' do
          @customer.update(stripe_id: 'sample_stripe_id')
          expect_any_instance_of(StripeClient).not_to receive(:create_customer)
          @charge.save!
        end
      end
    end # Charge

    describe 'Refund' do
      it 'Must NOT be the first Transaction on Order' do
        @charge.amount = -(@order.total - 1)
        @charge.valid?.should == false
        @charge.errors[:amount].should == ['a refund cannot be the first Transaction on an Order']
      end

      context 'After a Charge' do
        before do
          @charge.save!
          @refund = build(:refund, order: @order)
        end

        it 'must be less than -49' do
          @refund.amount = -49
          @refund.valid?.should == false
          @refund.errors[:amount].should == ['refund must be 50 cents or more']
        end

        it 'must be less than :amount' do
          @refund.amount = -(@order.total) -1
          @refund.valid?.should == false
          @refund.errors[:amount].should == ['cannot be less than Order total']
        end

        it 'must be less than the amount of ALL negative Refunds' do
          first_refund = create(:refund, order: @order, amount: -@order.total)

          second_refund = build(:refund, order: @order, amount: -100)

          second_refund.valid?.should == false
          second_refund.errors[:amount].should == ['cannot be less than Order total']
        end
      end
    end # Refund

    describe 'Orders w/ :amount less than 50' do
      before do
        @charge.amount = 49
      end

      it 'should not be valid' do
        @charge.valid?.should == false
        @charge.errors[:amount].include?('charge must be 50 cents or more').should == true
      end
    end
  end # Validations

  describe 'Associations' do
    it{ should belong_to :order }
  end # Associations

  describe 'Attributes' do
  end # Attributes

  describe 'Behaviors' do
    describe 'Executing' do
      before do
        allow(@charge).to receive(:charge!)
      end

      it 'should execute #charge! if Transaction is positive' do
        expect(@charge).to receive(:charge!)
        @charge.save!
      end

      it 'should execute #refund! if Transaction is negative' do
        @charge.save
        refund = build(:refund, order: @order)
        expect(refund).to receive(:refund!)
        refund.save!
      end
    end

    describe 'First Transaction' do
      specify 'If this is the First Transaction for Order, set amount to @order.total' do
        @charge.amount = nil
        expect{ @charge.save! }.to change{ @charge.amount }.from(nil).to(@order.total)
      end

      it 'should not set amount if amount is 0' do
        @charge.amount = 0
        expect{ @charge.save }.not_to change{ @charge.amount }
      end

      it 'should not set amount if this is not the first transaction' do
        @charge.save!
        new_charge = build(:charge, order: @order)
        expect{ new_charge.save }.not_to change{ new_charge.amount }
      end

      it 'should not set amount if this is not the first transaction' do
        @order.destroy
        expect{ @charge.save }.not_to change{ @charge.amount }
      end
    end
  end # Behaviors

  describe 'Methods' do
    describe '#transaction_type' do
      it 'should return "charge" if the Transaction is positive' do
        @charge.transaction_type.should == 'charge'
      end

      it 'should return "refund" if Transaction is negative' do
        refund = build(:refund)
        refund.transaction_type.should == 'refund'
      end
    end # transaction_type
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

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
    it{ should belong_to(:group).required(false) }
    it{ should belong_to(:menu).required(false) }

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
    describe 'Deleting or Archiving an Product' do
      before do
        @product.save!
      end

      it 'should delete if Product is not part of an Order' do
        expect{ @product.destroy }
              .to change{ Product.exists?(@product.id) }
              .from(true).to(false)
      end

      context 'Order exists' do
        before do
          @order_item = create(:order_item, product: @product)
        end

        it 'should NOT delete' do
          expect{ @product.destroy }.not_to change{ Product.exists?(@product.id) }
        end

        it 'should mark as :archived' do
          expect{ @product.destroy }
                .to change{ @product.archived }
                .from(false).to(true)

        end
      end
    end # Deleting or Archiving a Product
  end # Behaviors

  describe 'Methods' do
    describe '#exists_on_order?' do
      before do
        @product.save!
      end

      it 'should return false if no OrderItem for this Product exists' do
        @product.exists_on_order?.should == false
      end

      it 'should return true if any OrderItems for this Product exist' do
        create(:order_item, product: @product)
        @product.exists_on_order?.should == true
      end
    end
  end # Methods

  describe 'Class Methods' do
    before do
      @product.save!
    end

    describe 'Scopes' do
      before do
        @inactive_product = create(:product, active: false, account: @product.account)
      end

      describe '#active' do
        it 'should return all active products' do
          Product.active.should == [@product]
        end

        it 'should not return arcived Products' do
          @product.update(archived: true)
          Product.active.should == []
        end
      end # active

      describe '#inactive' do
        it 'should return any product that is not active' do
          Product.inactive.should == [@inactive_product]
        end

        it 'should not return arcived Products' do
          @inactive_product.update(archived: true)
          Product.inactive.should == []
        end
      end # inactive

      describe '#archived' do
        it 'should return products that are archived, regardless of their active state' do
          @product.update(archived: true)
          @inactive_product.update(archived: true)
          Product.archived.should == [@product, @inactive_product]
        end
      end # archived
    end
  end # Class Methods
end

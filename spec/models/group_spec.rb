describe Group, type: :model do
  before do
    @group = build(:group)
    @account = @group.account
  end

  describe 'Validations' do
    it{ should validate_presence_of :name }
    specify{ association_must_exist(@group, :account) }
  end # Validations

  describe 'Associations' do
    it{ should belong_to :account }
    it{ should belong_to(:menu).required(false) }

    it{ should have_many :products }


    specify '@product.menu must belong to accont' do
      @group.menu = create(:menu)
      @group.valid?.should == false
      @group.errors[:menu].should == ['does not belong to this account']
    end
  end # Associations

  describe 'Attributes' do
    specify ':active defaults to true' do
      @group.active.should == true
    end

    specify ':data defaults to and empty Hash' do
      @group.data.should == {}
    end
  end # Attributes

  describe 'Behaviors' do
  end # Behaviors

  describe 'Methods' do
  end # Methods

  describe 'Class Methods' do
    before do
      @group.save!
      @inactive_group = create(:group, :inactive, account: @group.account)
      @archived_group = create(:group, :archived, account: @group.account)
    end

    describe 'Scopes' do
      describe '#active' do
        it 'should return all active menus' do
          Group.active.should == [@group]
        end
      end

      describe '#inactive' do
        it 'should return any product that is not active or archived' do
          Group.inactive.should == [@inactive_group]
        end
      end

      describe '#archived' do
        it 'should return any product that is archived' do
          Group.archived.should == [@archived_group]
        end
      end
    end
  end # Class Methods
end

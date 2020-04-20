describe Group, type: :model do
  before do
    @group = build(:group)
  end

  describe 'Validations' do
    it{ should validate_presence_of :name }
    specify{ association_must_exist(@group, :account) }
  end # Validations

  describe 'Associations' do
    it{ should belong_to :account }
    it{ should belong_to :menu }

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
    end

    describe 'Scopes' do
      describe '#active' do
        it 'should return all active menus' do
          inactive_group = create(:group, active: false, account: @group.account)
          Group.active.should == [@group]
        end
      end
    end
  end # Class Methods
end

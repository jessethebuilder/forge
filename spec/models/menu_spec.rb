describe Menu, type: :model do
  before do
    @account = create(:account)
    @menu = build(:menu, account: @account)
  end

  describe 'Validations' do
    it{ should validate_presence_of :name }
    specify{ association_must_exist(@menu, :account) }
  end # Validations

  describe 'Associations' do
    it{ should belong_to :account }

    it{ should have_many :orders }
    it{ should have_many :groups }
    it{ should have_many :products }
  end # Associations

  describe 'Attributes' do
    specify ':active defaults to true' do
      @menu.active.should == true
    end

    specify ':data defaults to and empty Hash' do
      @menu.data.should == {}
    end
  end # Attributes

  describe 'Behaviors' do
    describe 'Deleting or Archiving a Group' do
      before do
        @menu.save!
      end

      it 'should delete if there are no associated OrderItems' do
        expect{ @menu.destroy }
              .to change{ Menu.exists?(@menu.id) }
              .from(true).to(false)
      end
    end # Deleting or Archiving an Order
  end # Behaviors

  describe 'Methods' do
  end # Methods

  describe 'Class Methods' do
    before do
      @menu.save!
      @inactive_menu = create(:menu, active: false, account: @account)
    end

    describe 'Scopes' do
      describe '#active' do
        it 'should return all active menus' do
          Menu.active.should == [@menu]
        end
      end


      describe '#inactive' do
        it 'should return any product that is not active' do
          Menu.inactive.should == [@inactive_menu]
        end
      end
    end
  end # Class Methods
end

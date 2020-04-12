describe Group, type: :model do
  before do
    @group = build(:group)
  end

  describe 'Validations' do
    specify{ association_must_exist(@group, :account) }
  end # Validations

  describe 'Associations' do
    it{ should belong_to :account }
    it{ should belong_to :menu }

    it{ should have_many :products }
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
  end # Class Methods
end

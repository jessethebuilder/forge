describe Menu, type: :model do
  before do
    @menu = build(:menu)
  end

  describe 'Validations' do

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
  end # Behaviors

  describe 'Methods' do
  end # Methods

  describe 'Class Methods' do
    before do
      @model.save!
    end
  end # Class Methods
end

describe Modelx, type: :model do
  before do
    @modelx = build(:modelx)
  end

  describe 'Validations' do
    specify{ association_must_exist(@modelx, :account) }
  end # Validations

  describe 'Associations' do
    it{ should belong_to :account }
  end # Associations

  describe 'Attributes' do
    specify ':active defaults to true' do
      @modelx.active.should == true
    end

    specify ':data defaults to and empty Hash' do
      @modelx.data.should == {}
    end
  end # Attributes

  describe 'Behaviors' do
  end # Behaviors

  describe 'Methods' do
  end # Methods

  describe 'Class Methods' do
    before do
      @modelx.save!
    end
  end # Class Methods
end

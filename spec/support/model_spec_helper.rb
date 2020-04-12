module ModelSpecHelper
  def association_must_exist(model, association)
    model.send("#{association.to_s}=", nil)
    model.valid?.should == false
    model.errors[association].should == ['must exist']
  end
end

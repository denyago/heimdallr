def run_sti_specs(base_news_model, fancy_news_model)
  before(:all) do
    base_news_model.destroy_all
    fancy_news_model.destroy_all
  end

  it "should handle entities creation" do
    fancy_news_model.restrict(nil).create!
    fancy_news_model.all.count.should == 1
  end
end


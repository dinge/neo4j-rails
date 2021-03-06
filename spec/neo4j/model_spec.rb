require File.expand_path('../../spec_helper', __FILE__)
require 'neo4j/model'

class IceCream < Neo4j::Model
  property :flavour
  index :flavour
  validates_presence_of :flavour
end

describe Neo4j::Model, "new" do
  before :each do
    @model = Neo4j::Model.new
  end
  subject { @model }

  it { should_not be_persisted }

  it "should allow access to properties before it is saved" do
    @model["fur"] = "none"
    @model["fur"].should == "none"
  end

  it "should fail to save new model without a transaction" do
    lambda { @model.save }.should raise_error
  end
end

describe Neo4j::Model, "load" do
  before :each do
    with_transaction do
      @model = Neo4j::Model.new
      @model.save
    end
  end

  it "should load a previously stored node" do
    result = Neo4j::Model.load(@model.id)
    result.should == @model
    result.should be_persisted
  end
end

describe Neo4j::Model, "save" do
  use_transactions
  before :each do
    @model = IceCream.new
    @model.flavour = "vanilla"
  end

  it "should store the model in the database" do
    @model.save
    @model.should be_persisted
    IceCream.load(@model.id).should == @model
  end

  it "should not save the model if it is invalid" do
    @model = IceCream.new
    @model.save.should_not be_true
    @model.should_not be_valid
    @model.should_not be_persisted
    @model.id.should be_nil
  end
end

describe Neo4j::Model, "find" do
  before :each do
    with_transaction do
      @model = IceCream.new
      @model.flavour = "vanilla"
      @model.save
    end
  end
  use_transactions

  it "should load all nodes of that type from the database" do
    IceCream.all.should include(@model)
  end

  it "should find a model by one of its attributes" do
    pending "problem with lucene indexing"
    IceCream.find(:flavour => "vanilla").to_a.should include(@model)
  end
end

describe Neo4j::Model, "lint" do
  before :each do
    @model = Neo4j::Model.new
  end

  include_tests ActiveModel::Lint::Tests
end

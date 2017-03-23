require 'rspec'

describe 'new RSpec syntax' do
  it "uses the new assertion syntax" do
    # new                           # deprecated
    expect(1 + 1).to eq(2)          # (1 + 1).should == 2
  end

  context "mocks and expectations" do
    let(:obj) do
      # new                          # deprecated
      double('foo')                  # obj = mock('foo')      
    end
    
    it "uses the new allow syntax for mocks" do
      # new                          # deprecated
      allow(obj).to receive(:bar)    # obj.stub(:bar)
    end

    it "uses the new expect syntax for expectations" do
      # new                          # deprecated
      expect(obj).to receive(:baz)   # obj.should_receive(:baz)
      
      obj.baz
    end    
  end
end

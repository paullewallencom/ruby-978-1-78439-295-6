describe 'matchers' do
  it "has a cryptic error message" do
    expect([1,2,3].include?(4)).to eq(true)    
  end
  
  it "tells us exactly what went wrong" do 
    expect([1,2,3]).to include(4)
  end
end
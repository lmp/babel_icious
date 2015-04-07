require "spec_helper"

module Babelicious

  describe BaseMap do
    
  end 
  
end 


shared_examples_for "an implementation of a mapping strategy" do
  describe "#dup" do
    
    it "deep dups all of its attributes" do
      dupd = @strategy.dup
      expect(dupd.opts.object_id).not_to eq(@strategy.opts.object_id)
      expect(dupd.path_translator.object_id).not_to eq(@strategy.path_translator.object_id)
    end
    
  end
  
end 

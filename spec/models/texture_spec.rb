# coding: utf-8
require 'spec_helper'

describe Texture do
  fixtures :textures
  it { Texture.new.should be_a_new(Texture) }
  
  describe "保存済みのもの" do
    before do
      @texture = Texture.first
    end
    it { @texture.should_not be_new_record }
  end
end

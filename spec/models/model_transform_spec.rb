# coding: utf-8
require 'spec_helper'

describe ModelTransform do
  fixtures :model_transforms
  it { ModelTransform.new.should be_a_new(ModelTransform) }
  
  describe "保存済みのもの" do
    before do
      @transform = ModelTransform.first
    end
    it { @transform.should_not be_new_record }
  end
end

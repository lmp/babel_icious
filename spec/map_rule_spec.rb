require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

module Babelicious

  describe MapRule do

    describe "setting source and target" do

      before(:each) do
        @map_rule = MapRule.new
      end

      context "#source=" do

        it "should set source mapping" do
          # given
          @map_rule.source = @source

          # expect
          expect(@map_rule.source).to eq(@source)
        end

      end

      context "#target=" do

        it "should set target mapping" do
          # given
          @map_rule.target = @target

          # expect
          expect(@map_rule.target).to eq(@target)
        end

      end

    end

    describe "getting source and target" do

      before(:each) do
        @source = double("XmlMap")
        @target = double("HashMap")
        @map_rule = MapRule.new(@source, @target)
      end

      context "#source" do

        it "should return source mapping" do
          # expect
          expect(@map_rule.source).to eq(@source)
        end

      end

      context "#target" do

        it "should return target mapping" do
          # expect
          expect(@map_rule.target).to eq(@target)
        end

      end

    end

    context "#filtered_source" do

      it "should delegate to source strategy" do
        # given
        source = double("HashMap", :class => HashMap)
        target = double("HashMap")
        map_rule = MapRule.new(source, target)

        # expect
        expect(HashMap).to receive(:filter_source).with({:foo => "bar"})

        # when
        map_rule.filtered_source({:foo => "bar"})
      end

      it "should return filtered source data structure for source strategy" do
        # given
        source = double("HashMap", :class => HashMap)
        target = double("HashMap")
        map_rule = MapRule.new(source, target)

        # expect
        expect(map_rule.filtered_source({:foo => "bar"})).to eq({:foo => "bar"})
      end

    end

    context "#initial_target" do

      before(:each) do
        # given
        source = double("XmlMap")
        target = double("HashMap", :class => HashMap)
        @map_rule = MapRule.new(source, target)
      end

      it "should delegate to target strategy" do
        # expect
        expect(HashMap).to receive(:initial_target)

        # when
        @map_rule.initial_target
      end

      it "should return initial target data structure for target strategy" do
        expect(@map_rule.initial_target).to eq({})
      end

    end

    context "source and target path shortcuts" do

      before(:each) do
        # given
        @source_path_translator = double("PathTranslator", :full_path => "foo/bar")
        @target_path_translator = double("PathTranslator", :full_path => "bar/foo")
        @source = double("XmlMap", :path_translator => @source_path_translator)
        @target = double("HashMap", :class => HashMap, :path_translator => @target_path_translator)
        @map_rule = MapRule.new(@source, @target)
      end

      context "#source_path" do

        it "should return full path for mapping" do
          expect(@map_rule.source_path).to eq(@source_path_translator.full_path)
        end

      end

      context "#target_path" do

        it "should return full path for mapping" do
          expect(@map_rule.target_path).to eq(@target_path_translator.full_path)
        end

      end

    end

    context "#translate" do

      before(:each) do
        @source = double("XmlMap")
        @target = double("HashMap", :opts => { }, :map_from => nil)
        @map_rule = MapRule.new(@source, @target)
        @target_data = { }
        @source_value = '<foo>bar</foo>'
      end

      context "target mapping to_proc option is set" do

        before(:each) do
          @path_translator = double("PathTranslator", :set_path => nil)
          @target_with_proc = double("HashMap", :opts => {:to_proc => Proc.new { }},
                                   :map_from => nil, :path_translator => @path_translator)
          @map_rule = MapRule.new(@source, @target_with_proc)
        end

        it "should delegate to path_translator" do
          # expect
          expect(@target_with_proc).to receive(:path_translator).and_return(@path_translator)

          # when
          @map_rule.translate(@target_data, @source_value)
        end

        it "should delegate mapping to target element" do
          # expect
          expect(@target_with_proc).to receive(:map_from).with(@target_data, @source_value)

          # when
          @map_rule.translate(@target_data, @source_value)
        end

      end

      it "should delegate mapping to target element" do
        # expect
        expect(@target).to receive(:map_from).with(@target_data, @source_value)

        # when
        @map_rule.translate(@target_data, @source_value)
      end

    end

  end
end

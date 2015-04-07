require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

module Babelicious

  describe MapDefinition do

    before(:each) do
      xml = '<foo>bar</foo>'
      @hash_map_klass = double("HashMapKlass", :initial_target => {})
      allow(MapFactory).to receive(:source).and_return(@source_element = double("XmlMap", :value_from => "bar"))
      allow(MapFactory).to receive(:target).and_return(@target_element = double("HashMap", :map_from => {}, :class => @hash_map_klass))
      @map_definition = MapDefinition.new
      @map_definition.direction = {:from => :xml, :to => :hash}
      @opts = {:to => "bar/foo", :from => "foo/bar"}
      @map_definition.register_rule(@opts)
    end


    describe "#register_condition" do

      it "should delegate to target map" do
        # expect
        expect(@target_element).to receive(:register_condition).with(:unless, :nil)

        # given
        @map_definition.register_condition(:unless, :nil)
      end

    end

    describe "#register_customized" do

      it "should delegate to target map element" do
        # expect
        expect(@target_element).to receive(:register_customized)

        # given
        @map_definition.register_customized
      end

    end

    describe "#register_from" do

      it "should create new source object" do
        # expect
        expect(MapFactory).to receive(:source).with({:from => :xml, :to => :hash}, {:from => "foo/bar"})

        # given
        @map_definition.register_from("foo/bar")
      end

      it "should add source to mappings array" do
        # given
        allow(MapRule).to receive(:new).and_return(map_rule = MapRule.new(@source_element, @target_element))
        @map_definition.reset

        # when
        @map_definition.register_from("foo/bar")

        # expect
        expect(@map_definition.rules).to eq([map_rule])
      end

      context "when argument is nil" do

        it "should raise an error" do
          expect(running { @map_definition.register_from(nil) }).to raise_error(MapDefinitionError)
        end
      end

    end

    describe "#register_include" do

      before(:each) do
        Mapper.reset
        @source_path_translator = double("PathTranslator")
        @target_path_translator = double("PathTranslator")
        @source_element = double("HashMap", :dup => (@dupd_source = double("HashMap", :path_translator => @source_path_translator)))
        @target_element = double("HashMap", :dup => (@dupd_target = double("HashMap", :path_translator => @target_path_translator)))
        @other_map_rule = double("MapRule", :source => @source_element, :target => @target_element)
        @other_map_definition = double("MapDefinition", :direction= => nil, :register_rule => nil, :rules => [@other_map_rule])
        Mapper.definitions[:another_mapping] = @other_map_definition
      end

      context "missing mapping key" do

        it "should raise an error" do
          expect(running { @map_definition.register_include }).to raise_error(MapDefinitionError)
        end

      end

      context "missing included mapping" do

        it "should raise an error" do
          expect(running { @map_definition.register_include(:foo) }).to raise_error(MapDefinitionError)
        end

      end

      it "should retrieve rules from included map definition" do
        # expect
        expect(@other_map_definition).to receive(:rules)

        # when
        @map_definition.register_include(:another_mapping)
      end

      it "should add its own rules to those from included map definition" do
        # when
        @map_definition.register_include(:another_mapping)

        # expect
        expect(@map_definition.rules.last.source).to eq(@dupd_source)
        expect(@map_definition.rules.last.target).to eq(@dupd_target)
      end

      context "when included mapping is nested" do

        it "should add its own " do
          # expect
          expect(@dupd_source.path_translator).to receive(:unshift).with("barf")
          expect(@dupd_target.path_translator).to receive(:unshift).with("barf")

          # when
          @map_definition.register_include(:another_mapping, {:inside_of => "barf"})
        end

      end
    end


    describe "#register_rule" do

      def do_process
        allow(@source_element).to receive(:class).and_return(@xml_map_klass = double("XmlMapKlass", :filter_source => @xml))
        @map_definition.reset
        @map_definition.direction = {:from => :xml, :to => :hash}
        @map_definition.register_rule(@opts)
      end

      it "should register target or source mapping" do
        # given
        allow(@source_element).to receive(:class).and_return(double("XmlMapKlass", :filter_source => @xml))
        @map_definition.reset
        @map_definition.direction = {:from => :xml, :to => :hash}
        map_rule = MapRule.new(@source_element, @target_element)
        allow(MapRule).to receive(:new).and_return(map_rule)

        # when
        @map_definition.register_rule(@opts)

        # expect
        expect(@map_definition.rules).to eq([map_rule])
      end

      describe "setting target" do

        describe "when map is called multiple times" do

          def do_process
            @map_definition.reset
            @map_definition.direction = {:from => :xml, :to => :hash}
            @map_definition.register_rule({:to => "bar/foo", :from => "foo/bar"})
            @map_definition.register_rule({:to => "bar/baz", :from => "foo/baz"})
            @map_definition.register_rule({:to => "bar/boo", :from => "foo/boo"})
          end

          it "should delegate creation of the initial target to the target element" do
            skip
            during_process {
              expect(@hash_map_klass).to receive(:initial_target).once.and_return({})
            }
          end

        end
      end

      it "should instantiate 'from' mapping element" do
        during_process {
          expect(MapFactory).to receive(:source).with(@map_definition.direction, @opts).and_return(@source_element)
        }
      end

      it "should instantiate 'to' mapping element" do
        during_process {
          expect(MapFactory).to receive(:target).with(@map_definition.direction, @opts).and_return(@target_element)
        }
      end

      context "when :to or :from are not set" do

        it "should raise an error" do
          expect(running { @map_definition.register_rule({})}).to raise_error(MapDefinitionError)
        end

      end
    end

    describe "#register_prepopulate" do

      before(:each) do
        @target_data = 'event/api_version'
      end

      it "should create new target object" do
        # expect
        expect(MapFactory).to receive(:target).with({:from => :xml, :to => :hash}, {:to => @target_data})

        # when
        @map_definition.register_prepopulate(@target_data)
      end

      it "should add source_proxy to rules array" do
        # when
        @map_definition.register_prepopulate(@target_data)

        # expect
        expect(@map_definition.rules.last.source).to be_a_kind_of(SourceProxy)
      end

      it "should return a source proxy object" do
        source = @map_definition.register_prepopulate(@target_data)
        expect(source).to be_a_kind_of(SourceProxy)
      end

    end

    describe "#register_to" do

      it "should create new target object" do
        # expect
        expect(MapFactory).to receive(:target).with({:from => :xml, :to => :hash}, {:to => '', :to_proc => nil})

        # given
        @map_definition.register_to
      end

      it "should add target to rules array" do
        # given
        map_rule = MapRule.new(@source_element)
        @map_definition.reset
        @map_definition.rules << map_rule
        @map_definition.register_to

        # expect
        expect(@map_definition.rules).to eq([map_rule])
      end

      context "if .from has not been set before calling .to" do

        it "should raise an error" do
          # given
          @map_definition.reset

          expect(running { @map_definition.register_to }).to raise_error(MapDefinitionError)
        end
      end
    end

    describe "#reset" do

      it "should set rules and direction to nil" do
        # given
        @map_definition.reset

        # expect
        expect(@map_definition.rules).to be_empty
        expect(@map_definition.direction).to be_nil
      end
    end

    describe "#translate" do

      before(:each) do
        @xml = '<foo>bar</foo>'
        allow(@source_element).to receive(:class).and_return(@xml_map_klass = double("XmlMapKlass", :filter_source => @xml))
        allow(@target_element).to receive(:opts).and_return({})
      end

      def do_process
        @map_definition.translate('<foo>bar</foo>')
      end

      it "should map target to elements for mapping" do
        during_process {
          expect(@target_element).to receive(:map_from).and_return({})
        }
      end

      it "should delegate the source to the source element for filtering" do
        during_process {
          expect(@xml_map_klass).to receive(:filter_source).with(@xml).once
        }
      end

      context "when block has been passed to #to method" do

        before(:each) do
          @path_translator = double("PathTranslator", :set_path => nil)
          allow(@target_element).to receive(:path_translator).and_return(@path_translator)
          @proc = double("Proc", :call => "baz")
          allow(@target_element).to receive(:opts).and_return({:to_proc => @proc})
        end

        it "should call proc" do
          during_process {
            expect(@proc).to receive(:call).and_return("baz")
          }
        end

        it "should set path on path translator" do
          during_process {
            expect(@path_translator).to receive(:set_path).with("baz")
          }
        end

        it "should map source to target element" do
          during_process {
            expect(@target_element).to receive(:map_from).with({}, "bar").and_return({})
          }
        end

      end
    end
  end

end


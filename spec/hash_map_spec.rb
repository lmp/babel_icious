require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

module Babelicious

  describe HashMap do

    describe ".initial_target" do

      it "should return an empty hash" do
        expect(HashMap.initial_target).to eq({})
      end
    end

    describe ".filter_source" do

      it "should return source unfiltered" do
        source = {:foo => {:bar => "baz"}}
        expect(HashMap.filter_source(source)).to eq(source)
      end
    end

    before(:each) do
      @path_translator = double("PathTranslator", :last_index => 0)
      @strategy = HashMap.new(@path_translator)
    end

    # This is defined in base_map_spec, but cannot be required, because
    # xml_map_spec would also require it, and that causes a name clash.
    #
    # Use bundle exec rspec spec/bash_map_spec.rb spec/hash_map_spec.rb
    it_should_behave_like "an implementation of a mapping strategy"

    describe "#map_from" do

      before(:each) do
        @target_hash = {}
        @path_translator = double("PathTranslator", :last_index => 0)
        @hash_map = HashMap.new(@path_translator)
        allow(@path_translator).to receive(:inject_with_index).and_yield(@target_hash, "bar", 0)
      end

      def do_process
        @hash_map.map_from(@target_hash, 'foo')
      end

      it "should set value in target map" do
        during_process {
          expect(@path_translator).to receive(:inject_with_index).with({})
        }
      end

      it "should apply value of source to key of target" do
        after_process {
          expect(@target_hash).to eq({"bar" => "foo"})
        }
      end

      describe "map condition is set" do

        before(:each) do
          allow(MapCondition).to receive(:new).and_return(@map_condition = double("MapCondition", :register => nil, :is_satisfied_by => true))
          @hash_map.register_condition(:when, nil) { |value| value =~ /f/ }
        end

        it "should ask map condition to verify source value" do
          during_process {
            expect(@map_condition).to receive(:is_satisfied_by).with("foo")
          }
        end

        describe "map condition verifies source" do

          it "should map hash" do
            during_process {
              expect(@path_translator).to receive(:inject_with_index).with({})
            }
          end

        end
      end

      describe "map condition is not set" do

        it "should ignore map condition" do
          during_process {
            expect(MapCondition).not_to receive(:new)
          }
        end

      end
    end

    describe "#register_condition" do

      it "should register condition with MapCondition" do
        # given
        allow(MapCondition).to receive(:new).and_return(map_condition = double("MapCondition", :register => nil))
        hash_map = HashMap.new(double("PathTranslator"))

        # expect
        expect(map_condition).to receive(:register) #.with(:when, an_instance_of(Proc))

        # when
        hash_map.register_condition(:when, nil) {|value| value =~ /f/ }
      end

    end

    describe "#value_from" do

      before(:each) do
        @target_hash = {}
        path_translator = PathTranslator.new("foo/bar")
        @hash_map = HashMap.new(path_translator)
      end

      it "should map value of element in path" do
        expect(@hash_map.value_from({:foo => {:bar => "baz"}})).to eq("baz")
      end

      context "hash value is false" do
        it "should have false and Not '' for false values" do
          expect(@hash_map.value_from({:foo => {:bar => false}})).to eq(false)
        end
      end

    end

  end

end

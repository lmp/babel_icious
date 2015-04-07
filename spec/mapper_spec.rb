require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

module Babelicious

  describe "Mapper" do

    before(:each) do
      allow(MapDefinition).to receive(:new).and_return(@map_definition = double("MapDefinition", :register_rule => nil, :direction= => nil))
    end

    describe ".config" do

      it "should yield instance of itself" do
        Mapper.reset
        Mapper.config(:foo) do |m|
          expect(m).to eq(Mapper)
        end
      end

      it "should take a mapping key to register the target map" do
        # given
        Mapper.reset
        Mapper.config(:foo) {}

        # expect
        expect(Mapper.current_map_definition_key).to eq(:foo)
      end

      describe "when a mapping key already exists" do

        it "should raise an error" do
          # given
          Mapper.config(:bar) { |m| m.direction :from => :xml, :to => :hash }

          # expect
          expect(running { Mapper.config(:bar) {} }).to raise_error(MapperError)
        end
      end

    end

    describe ".customize" do

      before(:each) do
        Mapper.reset
        Mapper.config(:foo) { |m| m.direction :from => :xml, :to => :hash}
      end

      it "should delegate it to target mapper" do
        # expect
        expect(@map_definition).to receive(:register_customized) #.with(:when, an_instance_of(Proc)).and_return(@when_conditions)

        # given
        Mapper.map({:to => "bar/foo", :from => "foo/bar"}).customize do |value|
          # the value of "bar/foo" is itself a hash {:bar => "a", :cuk => "b"}
          [{:bum => value[:bar], :coo => value[:cuk]}]
        end
      end

    end

    describe ".direction" do

      it "should set direction of the mapping" do
        # expect
        expect(@map_definition).to receive(:direction=).with({:from => :xml, :to => :hash})

        # given
        Mapper.reset
        Mapper.config(:foo) do |m|
          m.direction :from => :xml, :to => :hash
        end
      end

    end

    describe ".from" do

      it "should delegate source path to target mapper" do
        # expect
        expect(@map_definition).to receive(:register_from).with("foo/bar")

        # given
        Mapper.reset
        Mapper.from("foo/bar")
      end

    end


    describe ".include" do

      it "should delegate to map_definition" do
        # expect
        expect(@map_definition).to receive(:register_include).with(:another_mapping, {})

        # given
        Mapper.reset
        Mapper.include(:another_mapping)
      end

    end

    describe ".map" do

      before(:each) do
        Mapper.reset
        @opts = {:to => "bar/foo", :from => "foo/bar"}
        Mapper.config(:foo) { |m| m.direction :from => :xml, :to => :hash}
      end

      it "should register mappings" do
        # expect
        expect(@map_definition).to receive(:register_rule).with(@opts)

        # given
        Mapper.map @opts
      end

    end

    describe ".reset" do

      it "should reset direction" do
        # when
        Mapper.reset

        # expect
        expect(Mapper.direction).to eq({})
      end

      it "should reset mappings" do
        # when
        Mapper.reset

        # expect
        expect(Mapper.definitions).to eq({})
      end
    end

    describe ".prepopulate" do

      it "should delegate prepopulate data to target mapper" do
        # expect
        expect(@map_definition).to receive(:register_prepopulate).with("event/api_version")

        # given
        Mapper.reset
        Mapper.prepopulate("event/api_version")
      end

    end

    describe ".to" do

      it "should delegate target block to target mapper" do
        # expect
        expect(@map_definition).to receive(:register_to) #.with(kind_of(Proc))

        # given
        Mapper.reset
        Mapper.to do |value|
          if(value=="baz")
            "value/is/baz"
          else
            "value/is/not/baz"
          end
        end
      end

    end

    describe ".translate" do

      before(:each) do
        @xml = '<foo><bar>baz</baz></foo>'
        Mapper.reset
        Mapper.config(:foo) do |m|
          m.direction :from => :xml, :to => :hash
          m.map :from => "foo/bar", :to => "bar/foo"
        end
      end

      it "should call reset_document" do
        # expect
        expect(Mapper).to receive(:reset_document)

        # given
        allow(@map_definition).to receive(:translate).and_return({})
        Mapper.translate(:foo, @xml)
      end

      it "should map target elements" do
        # expect
        expect(@map_definition).to receive(:translate).with(@xml).and_return({})

        # given
        Mapper.translate(:foo, @xml)
      end

      describe "when no key exists for target mapper" do

        it "should raise an error" do
          expect(running { Mapper.translate(:bar, @xml) }).to raise_error(MapperError)
        end
      end

    end


    describe "mapping conditions" do

      before(:each) do
        Mapper.reset
        @opts = {:to => "bar/foo", :from => "foo/bar"}
        Mapper.config(:foo) { |m| m.direction :from => :xml, :to => :hash}
      end

      describe ".when" do

        it "should delegate it to target mapper" do
          # expect
          expect(@map_definition).to receive(:register_condition) #.with(:when, an_instance_of(Proc)).and_return(@when_conditions)

          # given
          Mapper.map(@opts).when do |value|
            value =~ /baz/
          end
        end

      end

      describe ".unless" do

        it "should delegate it to target mapper" do
          # expect
          expect(@map_definition).to receive(:register_condition).with(:unless, :nil) #.with(:when, an_instance_of(Proc)).and_return(@when_conditions)

          # given
          Mapper.map(@opts).unless(:nil)
        end

      end

    end

  end

end

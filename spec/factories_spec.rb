require "spec_helper"

module Babelicious

  describe "factories" do

    before(:each) do
      @direction = {:from => :xml, :to => :hash}
      @xml_map = double("XmlMap")
      @hash_map = double("HashMap")
      @path_translator = double("PathTranslator")
      allow(PathTranslator).to receive(:new).and_return(@path_translator)
    end

    describe MapFactory do

      describe ".source" do

        describe "when source is xml" do

          it "should instantiate XmlMap" do
            # expect
            expect(XmlMap).to receive(:new).with(@path_translator, {:from => "foo/bar"}).and_return(@xml_map)

            # given
            MapFactory.source(@direction, {:from => "foo/bar"})
          end
        end

        describe "when source is hash" do

          it "should instantiate HashMap" do
            # expect
            expect(HashMap).to receive(:new).with(@path_translator, {:from => "foo/bar"}).and_return(@hash_map)

            # given
            MapFactory.source({:from => :hash, :to => :xml}, {:from => "foo/bar"})
          end

        end
      end

      describe ".target" do

        describe "when target is hash" do

          it "should instantiate HashMap" do
            path_translator = double("PathTranslator")
            xml_map = double("XmlMap")

            # expect
            expect(HashMap).to receive(:new).with(@path_translator, {:to => "bar/foo"}).and_return(@hash_map)

            # given
            MapFactory.target(@direction, {:to => "bar/foo"})
          end

        end

        describe "when target is xml" do

          it "should instantiate XmlMap" do
            path_translator = double("PathTranslator")
            hash_map = double("HashMap")

            # expect
            expect(XmlMap).to receive(:new).with(@path_translator, {:to => "bar/foo"}).and_return(@xml_map)

            # given
            MapFactory.target({:from => :hash, :to => :xml}, {:to => "bar/foo"})
          end

        end

      end
    end
  end


  describe SourceProxy do

    before(:each) do
      @source_proxy = SourceProxy.new
    end

    describe ".filter_source" do

      it "should return source argument" do
        expect(SourceProxy.filter_source("foo")).to eq("foo")
      end

    end

    describe "#path_translator" do

      it "should return path_translator object" do
        expect(@source_proxy.path_translator).to be_an_instance_of(PathTranslator)
      end

    end

    describe "#value_from" do

      it "should return source_value" do
        # when
        @source_proxy.with("foo")

        # expect
        expect(@source_proxy.value_from).to eq("foo")
      end

    end

    describe "#with" do

      it "should set argument as source variable" do
        # when
        @source_proxy.with("foo")

        # expect
        expect(@source_proxy.value_from).to eq("foo")
      end

    end

  end
end

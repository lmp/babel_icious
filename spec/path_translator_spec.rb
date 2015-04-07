require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

module Babelicious

  describe PathTranslator do

    before(:each) do
      @translator = PathTranslator.new("bar/foo")
    end

    describe "#[]" do

      it "should return element from parsed path array at specified index" do
        expect(@translator[1]).to eq("foo")
      end
    end

    describe "#dup" do

      it "deep dups all of the attributes" do
        dupd = @translator.dup
        expect(dupd.full_path.object_id).not_to eq(@translator.full_path.object_id)
        expect(dupd.parsed_path.object_id).not_to eq(@translator.parsed_path.object_id)
      end

    end

    describe "#each" do

      it "should yield path elements array" do
        @translator.each do |element|
          expect(["bar", "foo"].include?(element)).to be true
        end
      end

    end

    describe "#last" do

      it "should return last element in path" do
        expect(@translator.last).to eq("foo")
      end
    end

    describe "#last_index" do

      it "should return index of last element in parsed path array" do
        expect(@translator.last_index).to eq(1)
      end
    end

    describe "#prepare_path" do

      it "should strip opening slashes" do
        expect(@translator.prepare_path("/foo/bar")).to eq("foo/bar")
      end

      it "should strip trailing slashes" do
        expect(@translator.prepare_path("foo/bar/")).to eq("foo/bar")
      end

    end

    describe "#size" do

      it "should return size of path elements" do
        expect(@translator.size).to eq(2)
      end

    end

    describe "#set_path" do

      def do_process
        @translator.set_path("foo/bar")
      end

      it "should set full_path" do
        after_process {
          expect(@translator.full_path).to eq("foo/bar")
        }
      end

      it "should set parsed_path" do
        after_process {
          expect(@translator.parsed_path).to eq(["foo", "bar"])
        }
      end

    end

    describe "#translate" do

      it "should split path elements into array" do
        expect(@translator.parsed_path).to eq(["bar", "foo"])
      end

      describe "leading '/'" do

        it "should remove leading '/' from path" do
          translator = PathTranslator.new("/bar/foo")

          expect(translator.parsed_path).to eq(["bar", "foo"])
        end

      end
    end

    describe "#unshift" do

      it "should appended element to beginning of full path" do
        # when
        @translator.unshift("baz")

        # expect
        expect(@translator.full_path).to eq("baz/bar/foo")
      end

      it "should push element to beginning of parsed path array" do
        # when
        @translator.unshift("baz")

        # expect
        expect(@translator.parsed_path).to eq(["baz", "bar", "foo"])
      end

      context "if multiple namespaces provided" do

        it "should split those namespaces when it pushes them onto parsed path array" do
          # when
          @translator.unshift("baz/boo")

          # expect
          expect(@translator.parsed_path).to eq(["baz", "boo", "bar", "foo"])
        end

      end

    end
  end
end

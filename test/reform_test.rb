require 'test_helper'

require 'active_record'
class Artist < ActiveRecord::Base
end
ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "#{Dir.pwd}/database.sqlite3"
)


class RepresenterTest < MiniTest::Spec
  class SongRepresenter < Reform::Representer
    property :title
    property :name
  end

  let (:rpr) { SongRepresenter.new(Object.new) }

  describe "#fields" do
    it "returns all properties as strings" do
      rpr.fields.must_equal(["title", "name"])
    end
  end
end

class FieldsTest < MiniTest::Spec
  describe "#new" do
    it "accepts list of properties" do
      fields = Reform::Fields.new([:name, :title])
      fields.name.must_equal  nil
      fields.title.must_equal nil
    end

    it "accepts list of properties and values" do
      fields = Reform::Fields.new(["name", "title"], "title" => "The Body")
      fields.name.must_equal  nil
      fields.title.must_equal "The Body"
    end

    it "processes value syms" do
      skip "we don't need to test this as representer.to_hash always returns strings"
      fields = Reform::Fields.new(["name", "title"], :title => "The Body")
      fields.name.must_equal  nil
      fields.title.must_equal "The Body"
    end
  end
end

class ReformTest < MiniTest::Spec
  let (:duran)  { OpenStruct.new(:name => "Duran Duran") }
  let (:rio)    { OpenStruct.new(:title => "Rio") }

  let (:comp) { OpenStruct.new(:name => "Duran Duran", :title => "Rio") }

  let (:form) { SongForm.new(comp) }


  describe "::properties" do
    it do
      Class.new(Reform::Form) do
        properties [:name, :title]
      end.new(comp).to_hash.must_equal({"name"=>"Duran Duran", "title"=>"Rio"})
    end
  end

  class SongForm < Reform::Form
    property :name
    property :title

    validates :name, :presence => true
  end

  describe "Composition" do
    class SongAndArtist < Reform::Composition
      map({:artist => [:name], :song => [:title]}) #SongAndArtistMap.representable_attrs
    end

    let (:comp) { SongAndArtist.new(:artist => @artist=OpenStruct.new, :song => rio) }

    it "delegates to models as defined" do
      comp.name.must_equal nil
      comp.title.must_equal "Rio"
    end

    it "raises when non-mapped property" do
      assert_raises NoMethodError do
        comp.raise_an_exception
      end
    end

    it "creates readers to models" do
      comp.song.object_id.must_equal rio.object_id
      comp.artist.object_id.must_equal @artist.object_id
    end

    describe "::map_from" do
      it "creates the same mapping" do
        comp =
        Class.new(Reform::Composition) do
          map_from(
            Class.new(Reform::Representer) do
              property :name,  :on => :artist
              property :title, :on => :song
            end
          )
        end.
        new(:artist => duran, :song => rio)

        comp.name.must_equal "Duran Duran"
        comp.title.must_equal "Rio"
      end
    end

    describe "#nested_hash_for" do
      it "returns nested hash" do
        comp.nested_hash_for(:name => "Jimi Hendrix", :title => "Fire").must_equal({:artist=>{:name=>"Jimi Hendrix"}, :song=>{:title=>"Fire"}})
      end

      it "works with strings" do
        comp.nested_hash_for("name" => "Jimi Hendrix", "title" => "Fire").must_equal({:artist=>{:name=>"Jimi Hendrix"}, :song=>{:title=>"Fire"}})
      end

      it "works with strings in map" do
        Class.new(Reform::Composition) do
          map(:artist => ["name"])
        end.new([nil]).nested_hash_for(:name => "Jimi Hendrix").must_equal({:artist=>{:name=>"Jimi Hendrix"}})
      end
    end
  end

  describe "(new) form with empty models" do
    let (:comp) { SongAndArtist.new(:artist => OpenStruct.new, :song => OpenStruct.new) }

    it "returns empty fields" do
      form.title.must_equal nil
      form.name.must_equal  nil
    end

    describe "and submitted values" do
      it "returns filled-out fields" do
        form.validate("name" => "Duran Duran")

        form.title.must_equal nil
        form.name.must_equal  "Duran Duran"
      end
    end
  end

  describe "(edit) form with existing models" do
    let (:comp) { SongAndArtist.new(:artist => duran, :song => rio) }

    it "returns filled-out fields" do
      form.name.must_equal  "Duran Duran"
      form.title.must_equal "Rio"
    end
  end

  describe "#validate" do
    let (:comp) { SongAndArtist.new(:artist => OpenStruct.new, :song => OpenStruct.new) }

    it "ignores unmapped fields in input" do
      form.validate("name" => "Duran Duran", :genre => "80s")
      assert_raises NoMethodError do
        form.genre
      end
    end

    it "returns true when valid" do
      form.validate("name" => "Duran Duran").must_equal true
    end

    it "exposes input via property accessors" do
      comp.artist.name.must_equal nil
      form.name.must_equal nil

      form.validate("name" => "Duran Duran")

      form.name.must_equal "Duran Duran"
      comp.artist.name.must_equal nil # don't touch model, yet.
    end

    # TODO: test errors. test valid.
    describe "invalid input" do
      class ValidatingForm < Reform::Form
        property :name
        property :title

        validates :name,  :presence => true
        validates :title, :presence => true
      end
      let (:form) { ValidatingForm.new(comp) }

      it "returns false when invalid" do
        form.validate({}).must_equal false
      end

      it "populates errors" do
        form.validate({})
        form.errors.messages.must_equal({:name=>["can't be blank"], :title=>["can't be blank"]})
      end
    end

    describe "method validations" do
      it "allows accessing models" do
        form = Class.new(Reform::Form) do
          property :name
          validate "name_correct?"

          def name_correct?
            errors.add :name, "Please give me a name" if model.artist.name.nil?
          end
        end.new(comp)

        form.validate({}).must_equal false
        form.errors.messages.must_equal({:name=>["Please give me a name"]})
      end
    end

    describe "UniquenessValidator" do
      # ActiveRecord::Schema.define do
      #   create_table :artists do |table|
      #     table.column :name, :string
      #   end
      # end
      #Artist.new(:name => "Racer X").save
      let (:comp) { SongAndArtist.new(:artist => Artist.new, :song => OpenStruct.new) }

      it "allows accessing the database" do
      end

      it "is valid when name is unique" do
        ActiveRecordForm.new(comp).validate({"name" => "Paul Gilbert", "title" => "Godzilla"}).must_equal true
      end

      it "is invalid and shows error when taken" do
        form = ActiveRecordForm.new(comp)
        form.validate({"name" => "Racer X"}).must_equal false
        form.errors.messages.must_equal({:name=>["has already been taken"], :title => ["can't be blank"]})
      end

      require 'reform/rails'
      class ActiveRecordForm < Reform::Form
        include Reform::Form::ActiveRecord
        model :artist, :on => :artist # FIXME: i want form.artist, so move this out of ActiveModel into ModelDelegations.

        property :name, :on => :artist
        property :title, :on => :title

        validates_uniqueness_of :name
        validates :title, :presence => true # have another property to test if we mix up.
      end
    end
  end

  describe "#errors" do
    it { form.errors.messages.must_equal({}) }

    it do
      form.validate({"name"=>""})
      form.errors.messages.must_equal({:name=>["can't be blank"]})
    end
  end


  describe "#save" do
    let (:comp) { SongAndArtist.new(:artist => OpenStruct.new, :song => OpenStruct.new) }
    let (:form) { SongForm.new(comp) }

    before { form.validate("name" => "Diesel Boy") }

    it "pushes data to models" do
      form.save

      comp.artist.name.must_equal "Diesel Boy"
      comp.song.title.must_equal nil
    end

    describe "#save with block" do
      it "provides data block argument" do
        hash = {}

        form.save do |data, map|
          hash[:name]   = data.name
          hash[:title]  = data.title
        end

        hash.must_equal({:name=>"Diesel Boy", :title=>nil})
      end

      it "provides nested symbolized hash as second block argument" do
        hash = {}

        form.save do |data, map|
          hash = map
        end

        hash.must_equal({:name=>"Diesel Boy"})
      end
    end
  end
end

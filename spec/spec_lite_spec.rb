require File.expand_path( File.join( File.dirname(__FILE__), "spec_helper.rb" ) )

require 'stickler/spec_lite'

describe Stickler::SpecLite do
  before do
    @specs = {
      :ruby => Stickler::SpecLite.new( 'foo', '0.4.2' ),
      :win  => Stickler::SpecLite.new( 'bar', '1.0.1', "x86-mswin32" ),
      :java => Stickler::SpecLite.new( 'jfoo', '0.4.2', 'jruby' )
    }
  end

  it "defaults to ruby platform" do
    @specs[:ruby].platform.should == Gem::Platform::RUBY
  end

  { [:ruby, 'file_name']      => "foo-0.4.2.gem",
    [:ruby, 'spec_file_name'] => "foo-0.4.2.gemspec" ,
    [:win , 'file_name']      => "bar-1.0.1-x86-mswin32.gem",
    [:win , 'spec_file_name'] => "bar-1.0.1-x86-mswin32.gemspec",
    [:java, 'file_name']      => 'jfoo-0.4.2-jruby.gem',
    [:java, 'spec_file_name'] => 'jfoo-0.4.2-jruby.gemspec',
  }.each do |params, result|
    platform, method = *params
    it "on a #{platform} gem ##{method} is #{result}" do
      @specs[platform].send( method ).should == result
    end
  end

  it "has an array format" do
    @specs[:win].to_a.should == [ 'bar', '1.0.1', 'x86-mswin32' ]
  end

  it "returns false when compared to something that does not resond to :name, :version or :platform_string" do
    x = @specs[:ruby] =~ Object.new
    x.should == false
  end

  it "can compare against anything that responds to :name, :version and :platform_string" do
    class OSpec
      attr_accessor :name
      attr_accessor :version
      attr_accessor :platform_string
    end

    o = OSpec.new
    o.name = @specs[:ruby].name
    o.version = @specs[:ruby].version
    o.platform_string = @specs[:ruby].platform_string
    r = @specs[:ruby] =~ o
    r.should == true
  end

  it "can be compared against another spec" do
    (@specs[:ruby] =~ @specs[:win]).should == false
  end

  it "can be compared against something with the same name and version but different platform" do
    list = []
    list << r = Stickler::SpecLite.new( 'alib', '4.2' )
    list << u = Stickler::SpecLite.new( 'alib', '4.2', 'x86-mswin32' ) 
    list.sort.should == [ r, u ]
  end

  it 'converts platform comparisons to something that can be compared' do
    list = []
    list << h2 = Stickler::SpecLite.new( 'htimes', '1.1.1', 'x86-mingw32' )
    list << h1 = Stickler::SpecLite.new( 'htimes', '1.1.1', 'java' )
    list.sort.should == [ h1, h2 ]
  end

  it "can be sorted" do
    list = @specs.values
    alib = Stickler::SpecLite.new( 'alib', '4.2' )
    list << alib
    list.sort.should == [ alib, @specs[:win], @specs[:ruby], @specs[:java] ]
  end

  it "knows when it is a prerelease specification" do
    spec = Stickler::SpecLite.new( 'prerelease', '1.2.3a' )
    spec.should be_prerelease
  end

  it "knows when it is not a prerelease specification" do
    spec = Stickler::SpecLite.new( 'prerelease', '1.2.3' )
    spec.should_not be_prerelease
  end

  it "needs to be version sortable" do
    a = Stickler::SpecLite.new( "foo", "1.0.3" )
    b = Stickler::SpecLite.new( "foo", "1.0.22" )
    c = Stickler::SpecLite.new( "foo", "1.0.17" )

    [ b, a, c ].sort.should == [ a, c, b ]

  end
end

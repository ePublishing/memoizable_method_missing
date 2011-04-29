require 'epublishing/memoizable_method_missing'

describe Epublishing::MemoizableMethodMissing do

  before(:all) do
    @dummy = DummyMmm.new
  end

  it "should call method_missing once" do
    @dummy.no_such_foo(22) { :a }.should == 'foo/22/a' # Call once to create method
    @dummy.should_not_receive(:method_missing)
    @dummy.no_such_foo(73) { :b }.should == 'foo/73/b'
  end

  it "should work with lambdas" do
    @dummy.no_lambda_foo.should == 'foofoofoo' # Call once to create method
    @dummy.should_not_receive(:method_missing)
    @dummy.no_lambda_foo.should == 'foofoofoo'
  end

  it "should call original method_missing if not memoized" do
    @dummy.not_memoized(5, 'z') { :foo }.should == [:handled_manually, 5, "z", :foo]
  end

  it "should throw missing method if not handled" do
    expect { @dummy.not_handled }.should raise_error(NoMethodError)
  end

  class DummyMmm

    extend Epublishing::MemoizableMethodMissing

    def method_missing(method, *args, &block)
      if method == :not_memoized
        [:handled_manually, args, yield].flatten
      else
        super
      end
    end

    memoize_method_missing do |method|
      if method.to_s =~ /^no_such_(.*)/
        "[#{$1.to_sym.inspect}, args.first, yield] * '/'"
      elsif method.to_s =~ /^no_lambda_(.*)/
        name = $1
        lambda { name * 3 }
      end
    end

  end

end

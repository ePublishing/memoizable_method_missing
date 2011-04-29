#--
# memoizable_method_missing.rb - Optimize method_missing usage
#++
#
# == Overview
#
# We Rubyists love method_missing, but it isn't always the most
# efficient way to do things.  Following ActiveRecord's lead, we
# want to have the ability to create a method definition for a given
# missing method (that would otherwise be handled by method_missing
# logic) so that subsequent requests to that method do not have to
# get handled by method_missing.
#
# NOTE:  This can be used in conjunction with method_missing in the
# case that there is some method_missing_logic that is dependant
# on the args and not just the method name.
#
# NOTE:  The return value of the memoize_method_missing block
# should be one of:
#
#   1) String -- which can be evaled into the method definition
#   2) Proc -- which can be set as the method definition
#   4) nil -- meaning the call should be forwarded along to method_missing
#
# NOTE:  Profiling with ruby-prof has shown speed improvements of 40-60%
# in using memoize_method_missing over just method_missing (after the initial
# cost of creating the method on the fly).  The test was minimal and only
# involved a simple regex.  More complex logic may result in even greater
# performance gains.  The performance difference between using an eval'ed
# String and a Proc (see NOTE above) was negligible.
#
# == Use
#
#   class Foo
#
#     extend Epublishing::MemoizableMethodMissing
#
#     def method_missing(method, *args, &block)
#       if method.to_s =~ /^by_array_(.*)/ and args.first == :all
#         do_something($1.to_sym, args.last)
#       else
#         super
#       end
#     end
#
#     memoize_method_missing do |method|
#       case method.to_s
#       when /^by_xyz_(.*)$/
#         "do_something #{$1.inspect}, args.first, yield"
#       when /^by_id_(\d+)$/
#         id = $1.to_i
#         lambda { do_something(id) }
#       when /^by_name_(.*)$/
#         name = $1
#         lambda do |a1, a2, &block|
#           do_something(name, a1 * a2, block.call)
#         end
#       end
#     end
#
#   end
#
#   Foo.new.by_xyz_bar(42) { :foo }      => do_something("bar", 42, :foo)
#   Foo.new.by_id_33                     => do_something(33)
#   Foo.new.by_name_chris(3, 2) { :foo } => do_something('chris', 6, :foo)
#   Foo.new.by_array_foo(:all, 7)        => do_something(:foo, 7)
#   Foo.new.by_array_foo(:bogus)         => NoSuchMethodError
#
# == Contact
#
#   - David McCullars <dmccullars@ePublishing.com>
#
module Epublishing
  module MemoizableMethodMissing

    def memoize_method_missing(&what_to_do)
      define_method :method_missing_with_memoization do |method, *args, &block|
        case to_do = what_to_do.call(method)
        when String
          self.class.class_eval "def #{method}(*args, &block); #{to_do} end", __FILE__, __LINE__
          send(method, *args, &block)
        when Proc
          self.class.send :define_method, method, &to_do
          send(method, *args, &block)
        else
          method_missing_without_memoization(method, *args, &block)
        end
      end

      alias_method :method_missing_without_memoization, :method_missing
      alias_method :method_missing, :method_missing_with_memoization
    end

  end
end

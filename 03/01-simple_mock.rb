class Object
  def self.mock(method_name, return_value)
    klass = self

    # store existing method, if there is one, for restoration
    existing_method = if klass.method_defined?(method_name) 
      klass.instance_method(method_name)
    else
      nil
    end
    
    klass.send(:define_method, method_name) do |*args|
      return_value
    end
    
    # execute the passed block with the mock in effect
    yield if block_given?
  ensure
    # restore klass to previous condition
    if existing_method 
      klass.send(:define_method, method_name, existing_method)
    else
      klass.send(:remove_method, method_name)
    end
  end
end

# $ irb -rsimple_stub.rb
# awesome_print loaded
# irb(main):001:0> puts "2 + 2 = #{2 + 2}"
# 2 + 2 = 4
# nil
# irb(main):002:0> Fixnum.mock(:+, 5) do
# irb(main):003:1*   puts "2 + 2 = #{2 + 2}"
# irb(main):004:1> end
# 2 + 2 = 5
# nil
# irb(main):005:0> puts "2 + 2 = #{2 + 2}"
# 2 + 2 = 4
# nil
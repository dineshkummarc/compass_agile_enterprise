require 'ostruct'

module ErpRules
  module RulesEngine
    ##
    #OpenStruct is part of ruby stdlib
    #This class adds methods to allow hash-like
    #behavior
    class Context < OpenStruct

      def initialize(hash=nil)
        if hash
          hash.each do |k,v|
            if v.class == Hash
              result = ErpRules::RulesEngine::Context.new(v)
              hash[k] = result
            elsif v.class == Array
              v.map! do |item|
                #ostruct requires objects passed to it on the constructr
                #to support #each
                if item.is_a? Enumerable
                  ErpRules::RulesEngine::Context.new(item)
                else
                  item
                end
              end
              #end Array case
            end
          end
        end
        super(hash)
      end

      def [](key)
        send(key)
      end

      ##
      #This will set a method on the struct
      #using array syntax.
      #Trying to set the argument in eval led to an error,
      #hence the 'send' call following it.
      def []=(key, *args)
        arg = args[0]
        eval("#{key} = nil", binding)

        if arg.class == Hash
          send("#{key}=", ErpRules::RulesEngine::Context.new(arg))
        else
          send("#{key}=", arg)
        end
      end

      #need this method in order to mimic []= behavior
      #using the method/attr syntax of OpenStruct
      def method_missing(mid, *args)
        if args[0].class == Hash
          args[0] = ErpRules::RulesEngine::Context.new(args[0])
        end
        super(mid, *args)
      end

    end
  end
end

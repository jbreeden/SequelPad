require_relative 'schema'

module SequelPad
  class ScriptContext
  
    attr_accessor :db, :logs
    
    # Initiailizes the ScriptContext
    # @param db The Sequel::Database object to use for database communications.
    def initialize(db)
      @db = db
      @logs = []
    end
    
    # On each invocation, shovels its parameter onto the #logs member.
    # By default, #logs is simply an array, but may be defined as a custom
    # object by the client to this class to provide custom log handling.
    def log message
      @logs << message
    end
    
    # Attempts to locate a schema whose name matches the method being called. If
    # a match is found, a method by that name is defined and invoked, which returns
    # an instance of SequelPad::Schema. Otherwise, NoMethodError is raised.
    def method_missing(name, *args, &block)
      if self.respond_to? name.downcase
        return self.send(name.downcase)
      end
      
      # If we're not connected to a db, the rest won't work so just fail
      fail "The script context has no method named #{name} defined" unless @db
    
      matched_schema = SequelPad.get_schemas.find { |s| s.to_s.downcase == name.to_s.downcase }
      matched_table = $db.tables.find {|t| t.to_s.downcase == name.to_s.downcase }
      
      unless matched_schema || matched_table
        fail NoMethodError.new "'#{name}' does not match any schema name, or any table in the default schema"
      end
      
      if matched_schema
        instance_variable_set("@#{name.downcase}", Schema.new(@db, matched_schema))
      elsif matched_table
        instance_variable_set("@#{name.downcase}", @db[matched_table.to_sym])
      end
      self.define_singleton_method(name.downcase) do
        instance_variable_get("@#{name.downcase}")    
      end
        
      self.send(name)
    end
  end # class ScriptContext
end # module SequelPad
module SequelPad
  class Schema
    attr_reader :name, :tables, :views
    
    # Initialized with the name of the schema and a Sequel::Database object
    # @param db The Sequel::Database object to use for retrieving data
    # @param name The name of the schema this object represents
    def initialize(db, name)
      @name = name.to_sym
      @db = db
      @tables_loaded = false
      
      @tables = @db.tables(schema: @name)        
      @tables.each do |table|
        self.define_singleton_method "#{table.downcase}" do
          @db["#{@name}__#{table}".to_sym]
        end
      end
      
      @views = @db.views(schema: @name)
      @views.each do |view|
        self.define_singleton_method "#{view.downcase}" do
          @db["#{@name}__#{view}".to_sym]
        end
      end
    end
    
    # On first method_missing invocation, an accessor method is 
    # defined for each table in the schema. Then, the attempted
    # method call is tried again.
    def method_missing(name, *args, &block)
      if self.respond_to? name.downcase
        self.send(name.downcase)
      else
        raise NoMethodError.new "#{@name} schema has no tables or views matching '#{name}'"
      end
    end
    
  end # class Schema
end # module SequelPad
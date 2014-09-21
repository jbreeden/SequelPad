$0 = 'SequelPad' # Avoids error when requiring pg
require 'rubygems'
require 'pp'
require 'pg'
require 'sequel'
require 'socket'

module App
  include Predefs
  
  def self.connect
    # Try to open a tcp socket to see if a connection can be made
    TCPSocket.new($settings[:host], $settings[:port])
  
    $db = Sequel.connect(
      adapter: 'postgres', 
      host: $settings[:host], 
      port: $settings[:port], 
      database: $settings[:database], 
      user: $settings[:username], 
      password: $settings[:password]
    )
    set_schemas(get_schemas)
    save_settings
    true
  rescue Exception => ex
    alert "Unable to connect to host #{$settings[:host]} on port #{$settings[:port]}\n#{ex}"
    false
  end
  
  def self.disconnect
    $db.disconnect
    $db = nil
  end
  
  def self.get_schemas
    $db[:information_schema__schemata].
      select(:schema_name).
      map { |schema| schema[:schema_name] }.
      reject { |name| name =~ /pg_(toast|temp|catalog)/}
  end
  
  def self.get_tables(schema = nil)
    return [] unless $db
    if schema
      $db.tables(schema: schema).sort
    else
      $db.tables.sort
    end
  end

  def self.save_settings
    File.open("./scripts/settings.rb", "w") do |f|
      f.print "$settings = "
      PP.pp $settings, f
    end
  end

  def self.run_script (script)
    Grid.clear
    Grid.refresh
    script_context = SequelPad::ScriptContext.new($db)
    results = script_context.instance_eval(script)
    if results.kind_of? Sequel::Dataset
      print_dataset(results)
    elsif results.kind_of?(Hash)
      print_hash(results)
    elsif (results.kind_of?(Array) && results.all? { |r| r.kind_of?(Array) })
      print_matrix(results)
    elsif results.kind_of?(Enumerable)
      print_list(results)
    else
      print_value(results)
    end
    Grid.auto_size_by_column_width(true)
    Grid.auto_size_by_label_width
    Grid.refresh
  rescue Exception => ex
    alert ex
    nil
  end
  
  def self.print_dataset(results)
    return if results.count == 0
    columns = nil
    results.each do |result|
      unless columns
        columns = result.keys
        Grid.set_columns columns.map { |col| col.to_s}
      end
      
      Grid.add_row result.values
    end
  end
  
  def self.print_hash(results)
    Grid.set_columns ["Key", "Value"]
    results.each do |e|
      Grid.add_row e
    end
  end
  
  def self.print_matrix(results)
    return if results.length == 0
    col_count = results.max_by { |result| result.count }.count
    Grid.set_columns((1..(col_count)).map { |i| i.to_s })
    results.each do |row|
      Grid.add_row row
    end
  end
  
  def self.print_list(results)
    Grid.set_columns ['Value']
    results.each do |result|
      Grid.add_row [result]
    end
  end
  
  def self.print_value(value)
    Grid.set_columns ['Value']
    Grid.add_row([value]);
  end
 end

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
    
      matched_schema = App.get_schemas.find { |s| s.to_s.downcase == name.to_s.downcase }
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
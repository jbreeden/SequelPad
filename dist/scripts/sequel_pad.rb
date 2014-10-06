$0 = 'SequelPad' # Avoids error when requiring pg
require 'rubygems'
require 'pp'
require 'pg'
require 'sequel'
require 'socket'
require_relative 'sequel_pad/script_context'
require_relative 'sequel_pad/schema'
require_relative 'sequel_pad/printer'
require_relative 'sequel_pad/gui_printer'
require_relative 'sequel_pad/html_printer'

# Tables required first take precedence
# ie: flat_array_table & hashes_table can both
#     represent an array of hashes, but since
#     hashes_table is required first, it will
#     be used to generate the table.
require_relative 'sequel_pad/table'
require_relative 'sequel_pad/dataset_table'
require_relative 'sequel_pad/hashes_table'
require_relative 'sequel_pad/matrix_table'
require_relative 'sequel_pad/flat_array_table'
require_relative 'sequel_pad/hash_table'
require_relative 'sequel_pad/value_table'

# load user-defined scripts
Dir[File.dirname(__FILE__) + "/user_scripts/*.rb"].each do |user_script|
  require user_script
end

module SequelPad
  
  def self.connect
    $db = Sequel.connect(
      adapter: 'postgres', 
      host: $settings[:host], 
      port: $settings[:port], 
      database: $settings[:database], 
      user: $settings[:username], 
      password: $settings[:password]
    )
    raise "Connection failed" unless $db.test_connection
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
    ScriptContext.new($db).schemas
  rescue Exception => ex
    alert ex
    []
  end
  
  def self.get_tables(schema = nil)
    return [] unless $db
    if schema
      $db.tables(schema: schema).sort
    else
      $db.tables.sort
    end
  rescue Exception => ex
    alert ex
    []
  end
  
  def self.get_views(schema = nil)
    return [] unless $db
    if schema
      $db.views(schema: schema).sort
    else
      $db.views.sort
    end
  rescue Exception => ex
    alert ex
    []
  end

  def self.save_settings
    File.open("./scripts/settings.rb", "w") do |f|
      f.print "$settings = "
      PP.pp $settings, f
    end
  end
  
  def self.export_file_types
    Printer.exporters.keys
  end

  def self.run_script (script)
    printer = GuiPrinter.new
    script_context = ScriptContext.new($db)
    results = script_context.instance_eval(script)
    table = Table.from(results)
    printer.print(table)
  rescue Exception => ex
    alert ex
    nil
  end
  
  def self.exec_to_file (script, file_name, exporter)
    if exporter.kind_of? Numeric
      printer = Printer.exporters.values[exporter].new
    else # Assuming a printer class has been supplied...
      printer = exporter.new
    end
    script_context = ScriptContext.new($db)
    results = script_context.instance_eval(script)
    table = Table.from(results)
    printer.print(table, file_name)
  rescue Exception => ex
    alert "#{ex}"
    nil
  end
end

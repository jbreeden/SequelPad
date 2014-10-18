# predefs.rb re-opens the ScriptContext class to add
# methods "pre-defined" by the user. By addings them
# to the ScriptContext class, they can be used without
# qualification withing SequelPad scripts.

module SequelPad
  class ScriptContext
    def get_tables_by_row_count(schema)
      tables = $db.tables schema: schema

      table_lengths = {}
      tables.each do |table|
        table_lengths[table] = $db["#{schema}__#{table}".to_sym].count
      end
    
      table_lengths.sort_by { |key, value| value }
    end
    
    def make_aliases(dataset, &block)
      aliases = dataset.columns.zip(dataset.columns.map(&block)).map do |col, col_alias|
        Sequel.as(col, col_alias)
      end
    end

    # Takes a schema name, and a `matches` hash.
    # The hash should contain columns names as keys,
    # and regular expressions as values, and is used
    # to filter the results. That is, rows matching
    # any one of the matches is returned
    def foreign_keys(schema_name, matches = nil)
      fks = self.send(schema_name.to_sym).tables.flat_map do |table|
        results = $db.foreign_key_list("#{schema_name}__#{table}".to_sym)
        results.each do |fk| 
          fk['Name'] = fk[:name]
          fk.delete :name
          fk['From Schema'] = schema_name
          fk['From Table'] = table
          fk['From Columns'] = fk[:columns]
          fk.delete :columns
          fk['To Schema'] = fk[:table].table
          fk['To Table'] = fk[:table].column
          fk.delete :table
          fk['To Columns'] = fk[:key]
          fk.delete :key
          fk['On Update'] = fk[:on_update]
          fk.delete :on_update
          fk['On Delete'] = fk[:on_delete]
          fk.delete :on_delete
          fk.delete :deferrable
        end
        
        if matches
          results.select do |row|
            matches.keys.any? do |col|
              !row[col].nil? && row[col] =~ matches[col]
            end
          end
        else
          results
        end
      end
    end
  end
end


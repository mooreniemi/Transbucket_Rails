# Rails 4.2 mutates the schema-default string while dumping boolean columns.
# Ruby 3.1 returns frozen "true"/"false" strings for these values, so the
# legacy dumper can silently omit an entire table from schema.rb.
module TransbucketSchemaDumperRuby31Compatibility
  def prepare_column_options(column, types)
    spec = {}
    spec[:name] = column.name.inspect
    spec[:type] = column.type.to_s
    spec[:null] = 'false' unless column.null

    limit = column.limit || types[column.type][:limit]
    spec[:limit] = limit.inspect if limit
    spec[:precision] = column.precision.inspect if column.precision
    spec[:scale] = column.scale.inspect if column.scale

    default = schema_default(column).dup if column.has_default?
    spec[:default] = default unless default.nil?

    spec
  end
end

ActiveRecord::ConnectionAdapters::ColumnDumper.prepend(
  TransbucketSchemaDumperRuby31Compatibility
)

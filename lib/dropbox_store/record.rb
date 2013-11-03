module DropboxStore

	class Record

		# table definition for this record
		attr_reader :table

		# unique row identifier
		attr_reader :row_id

		#
		#  Initialize this record
		#
		def initialize(data, table, row_id, content)
			@dirty = false

			@data = data
			@table = table
			@original_content = content.clone
			@row_id = row_id
			@content = content
		end

		def values
			@content.clone
		end

		def []=(name, value)
			raise "unknown field" unless @table.field_exists? name
			@content[name] = value
			@dirty |= @original_content[name] != @content[name]
		end

		def [](name)
			raise "unknown field" unless @table.field_exists? name
			@content[name]
		end

		def revert
			@content = @original_content.clone
		end

		def dirty?
			@dirty
		end

	end

end


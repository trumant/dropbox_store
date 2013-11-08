require 'securerandom'

module DropboxStore

	class Record

		# table definition for this record
		attr_reader :table

		# unique row identifier
		attr_reader :row_id

		# new record boolean
		attr_reader :new_record

		#
		#  Initialize this record
		#
		def initialize(data, table, row_id = nil, content = {})

			@dirty = false

			@data = data
			@table = table
			@original_content = content.clone

			if row_id.nil? then
				@row_id = SecureRandom.uuid.gsub /\-/, ''
				@new_record = true
			else
				@row_id = row_id
				@new_record = false
			end

			@content = content

			# extend this instance with helper functions defined for that table
			if not @table.behaviors.nil? then
			 	self.send :extend, table.behaviors
			end
		end

		def values
			@content.clone
		end

		def []=(name, value)
			raise "unknown field" unless @table.field_exists? name
			@content[name.to_s] = value
			@dirty |= (@original_content[name] != @content[name])
		end

		def [](name)
			raise "unknown field" unless @table.field_exists? name
			@content[name.to_s]
		end

		def revert!
			@content = @original_content.clone
			@dirty = false
		end

		def save!
			@data.save(self)
			@original_content = @content.clone
			@dirty = false
		end

		def remove!
			@data.remove(self)
		end

		def dirty?
			@dirty
		end

	end

end


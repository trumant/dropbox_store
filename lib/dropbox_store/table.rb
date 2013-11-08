module DropboxStore

	registered_tables = []

	#
	# 	A field is part of a table description
	#
	class Field 

		attr_reader :name
		attr_reader :type

		@@valid_types = %q{string int float bool bytes timestamp}

		def initialize(name, type)
			unless @@valid_types.include? type then
				raise "unknown type `#{type}`, please use one of the following `#{@@valid_types}`" 
			end

			# setup values
			@name = name
			@type = type
		end

	end

	#
	# A table has one or more fields
	#
	class Table


		#
		#  Constructor
		#
		def initialize
			DropboxStore::registered_tables << self
			@fields = []
			@filters = []
			@table = nil
			@behaviors = nil
		end

		# ---------------------------------------------------------------------------------------------------
		# 	Behaviors
		# ---------------------------------------------------------------------------------------------------
		
		def self.behaviors(behaviors = nil)
			if not behaviors.nil? then
				@behaviors = behaviors
			else
				@behaviors
			end
		end


		# ---------------------------------------------------------------------------------------------------
		# 	Table name
		# ---------------------------------------------------------------------------------------------------

		def self.table_name(name = :undefined)
			if name == :undefined
				return @table
			else
				@table = name
			end
		end

		# ---------------------------------------------------------------------------------------------------
		# 	Field related setters
		# ---------------------------------------------------------------------------------------------------

		def self.field_exists?(name)
			not (@fields.find { |f| f.name == name.to_sym }.nil?)
		end


		def self.fields
			@fields
		end

		def self.bool(name)
			field(name, "bool")
		end

		def self.string(name)
			field(name, "string")
		end

		def self.int(name)
			field(name, "int")
		end

		def self.float(name)
			field(name, "float")
		end

		def self.bytes(name)
			field(name, "bytes")
		end

		def self.timestamp(name)
			field(name, "timestamp")
		end

		#
		#   Add a field with name `name` of type `type`
		#
		def self.field(name, type)
			@fields ||= []
			@fields << Field.new(name, type)
			sanity_check
		end

		# ---------------------------------------------------------------------------------------------------
		#    Persist hooks one can override in table implementations
		# ---------------------------------------------------------------------------------------------------

		def before_save(record)
		end

		def before_update(record)
		end

		def before_insert(record)
		end

		def before_remove(record)
		end

		# ---------------------------------------------------------------------------------------------------
		# 	Utility methods
		# ---------------------------------------------------------------------------------------------------

		#
		#  Make sure there are no duplicate fields
		#
		def self.sanity_check
			has_duplicates = @fields.map { |f| f.name }.uniq.length != @fields.length
			raise "just inserted duplicate field, aborting" if has_duplicates
		end

	end

end


module DropboxStore

	class Data

		attr_reader :ctx
		attr_reader :tables
		attr_reader :snapshot
		attr_reader :datastore_id

		def initialize(ctx, datastore_id, &block)
			@ctx = ctx
			@tables = []
			@datastore_id = datastore_id
			@snapshot = []

			yield(self) if block 
			refresh
		end
		
		# ---------------------------------------------------------------------------------------------------
		#    Functions you can use in the constructors initblock
		# ---------------------------------------------------------------------------------------------------

		def table(table_class)
			@tables << table_class
		end

		# ---------------------------------------------------------------------------------------------------
		#     Handles data-input
		# ---------------------------------------------------------------------------------------------------

		#
		# Refresh the data by loading a new snapshot
		#
		def refresh
			# get handle if not yet available
			if not @ctx.active_store or @ctx.active_store[:dsid] != @datastore_id then 
				DropboxStore::Datastores.create_local(@ctx, @datastore_id)
			end

			# retrieve snapshot
			@snapshot = DropboxStore::Store.get_snapshot(@ctx)
		end

		def all
			query { true }
		end

		def find_by_id(row_id)
			list = query { |record| record.row_id == row_id }
			list.empty? ? nil : list.first
		end

		#
		#   Find record instances for specific query
		#
		def query(&code)
			data_instance = self
			result_records = []
			@snapshot["rows"].each do |row|
				record = DropboxStore::Record.new(
						data_instance,
						table_for(row), 
						row["rowid"],
						row["data"]
					)
				keep = code.call(record)

				result_records << record if keep
			end

			# map found elements to datastore.record objects
			return result_records
		end

		def record(table)
			DropboxStore::Record.new(self, table)
		end

		def table_for(row)
			@tables.find { |t| t.table_name == row['tid'] }
		end

		def remove(record)
			raise "Cannot delete a new record" if record.new_record
			DropboxStore::Store::put_delta(@ctx, [["D", record.table.table_name, record.row_id]])
			@snapshot["rows"].delete_if { |r| r["rowid"] == record.row_id }
		end

		def save(record)
			return unless record.dirty? 

			if record.new_record then
				change = ["I", record.table.table_name, record.row_id, record.values]

				# add record to snapshot
				@snapshot["rows"] << { 
					"tid" => record.table.table_name, 
					"row_id" => record.row_id,
					"data" => record.values 
				}

			else
				field_op_dict = {}
				record.values.each { |key, val| field_op_dict[key] = ["P", val] }
				change = ["U", record.table.table_name, record.row_id, field_op_dict]

				# merge changes back into @snapshot
				row = @snapshot["rows"].find { |r| r["tid"] == record.table.table_name and r["row_id"] == record.row_id }
				row["data"] = record.values
			end

			DropboxStore::Store::put_delta(@ctx, [change])
		end

	end

end
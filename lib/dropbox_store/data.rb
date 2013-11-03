
module DropboxStore

	class Data

		attr_reader :ctx
		attr_reader :tables
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
			if not @ctx.active_store or @ctx.active_store.dsid == @datastore_id then 
				DropboxStore::Datastores.get(@datastore_id)
			end

			# retrieve snapshot
			@snapshot = DropboxStore::Store.get_snapshot(@ctx)
		end

		#
		#   Find record instances for specific query
		#
		def query(&code)
			result_rows = []
			@snapshot["rows"].each do |row|
				keep = code.call(row)
				results_rows << row if keep
			end

			# map found elements to datastore.record objects
			return result_rows.map do |row| 
					Datastore::Record.new(
						@data, 
						table_for(row), 
						row["rowid"],
						row["ata"]
					)
				}
		end

		def table_for(row)
			@tables.find { |t| t.table_name == row['tid'] }
		end

		def save(record)
			return unless record.dirty? 
			puts "Storing #{record}"
		end


	end

end

# example usages

snapshot = DropboxStore::Data.new(ctx) do |s|
	s.table String
end	

results = snapshot.query { |r| r["name"] == "marnix" }

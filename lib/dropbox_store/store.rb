module DropboxStore

	module Store

		#
		#   retrieve deltas starting from a specific version
		#
		def self.get_deltas(ctx, starting_at_rev = nil)
			if ctx.nil? or ctx.active_store.nil? then
				raise "no active datastore, aborting"
			end

			result = 
				DropboxStore::message(
					ctx,
					'datastores/get_deltas', 
					{
						handle: ctx.active_store[:handle], 
						rev: starting_at_rev.nil? ? ctx.active_store[:rev] : starting_at_rev
					}
				)

			raise result["notfound"] if result["notfound"]
			raise result["error"] if result["error"]

			result
		end

		#
		#  Puts delta into known latest revision and updates revision in active_store with new
		#
		def self.put_delta(ctx, deltas)
			if ctx.nil? or ctx.active_store.nil? then
				raise "no active datastore, aborting"
			end

			result = 
				DropboxStore::message(
						ctx, 
						'datastores/put_delta', { 
							handle: ctx.active_store[:handle], 
							rev: ctx.active_store[:rev], 
							changes: deltas.to_json
						}
					)

			raise result["conflict"] if result["conflict"]
			raise result["error"] if result["error"]

			ctx.active_store[:rev] = result["rev"]

			result

		end

		def self.get_snapshot(ctx)
			if ctx.nil? or ctx.active_store.nil? then
				raise "no active datastore, aborting"
			end

			result = DropboxStore::message(ctx, 'datastores/get_snapshot', { handle: ctx.active_store[:handle] })

			raise result["notfound"] if result["notfound"]
			result
		end


	end

end
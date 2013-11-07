module DropboxStore

	module Datastores

		#
		#  List all datastores
		#
		def self.list(ctx)
			result = DropboxStore::message(ctx, 'datastores/list_datastores') 
			raise result["error"] if result["error"]
			
			return {
			  names: result["datastores"].collect { |store| store["dsid"] }, 
			  stores: result["datastores"]
			}
		end

		# 
		#  Get a handle to a datastore with name 'dsid'
		#
		def self.get(ctx, dsid)
			result = DropboxStore::message(ctx, 'datastores/get_datastore', { :dsid => dsid })

			raise result["notfound"] if result["notfound"]

			ctx.active_store = { 
				dsid: dsid,
				rev: result['rev'], 
				handle: result['handle'] 
			}
		end

		#
		# 	Create a local datastore (user-specific) with name 'dsid'
		#
		def self.create_local(ctx, dsid, &block)
			result = DropboxStore::message(ctx, 'datastores/get_or_create_datastore', { :dsid => dsid })

			if !result["rev"] then
				raise "Unable to create local database #{dsid}, server response: #{result.inspect}"
			end

			if result["created"] and block then
				yield ctx
			end

			ctx.active_store = { 
				dsid: dsid,
				rev: result['rev'], 
				handle: result['handle'] 
			}
		end

		#
		#   Create a global datastore (application specific) with name 'dsid'
		#
		def self.create_global(ctx, dsid, &block)
			result = DropboxStore::message(ctx, 'datastores/create_datastore', { :dsid => dsid })

			if !result["rev"] then
				raise "Unable to create global database #{dsid}, server response: #{result.inspect}"
			end

			if result["created"] and block then
				yield ctx
			end

			ctx.active_store = { 
				dsid: dsid,
				rev: result['rev'], 
				handle: result['handle'] 
			}

		end

		#
		#   Delete a data-store 
		#
		def self.delete(ctx, names)

			names = [names].flatten

			stores = list(ctx)

			names.each do |dsid|
				store_with_id = stores[:stores].find { |s_info| s_info["dsid"] == dsid }
				if not store_with_id then
					raise "no datastore with dsid `#{dsid}` found"
				end

				handle = store_with_id["handle"]
				result = DropboxStore::message(ctx, 'datastores/delete_datastore', { :handle => handle })
				raise result["notfound"] if result["notfound"]

				# unset active store if we just deleted our current one
				if ctx.active_store and ctx.active_store[:dsid] == dsid then
					ctx.active_store = nil
				end
			end

			true
		end

	end

end
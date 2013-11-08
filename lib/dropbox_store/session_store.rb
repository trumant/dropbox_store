module DropboxStore

	module SessionStore

		def self.included(class_object)

			class_object.class_eval do

				before_filter :session_grab_filter

				def session_grab_filter
					@local_session = session
				end

				#
				#   Create a store definition that will be initialized at a later point
				#
				def self.store(datastore_id, tables = [])
					if @store_definition_descriptor then
						raise "can only define one store_definition at a time, make sure you're not inheriting the definition"
					end

					@@store_definition_descriptor = {
						datastore_id: datastore_id,
						tables: tables
					}
				end


				#
				#   Get the active datastore so we can easily query it
				#
				def datastore()

					if not @local_session[:dropbox_context] then
						raise "datastore not initialized, make sure you have retrieved a token " +
							  "(include DropboxStore::TokenFilter and add before_filter :requires_token)"
					end

					# has a session?
					if not  DROPBOX_CONTEXTS[@local_session[:dropbox_context] + "_DATA"] then
						ctx = DROPBOX_CONTEXTS[@local_session[:dropbox_context]]

						# generate a code block that is passed to the datastore constructor
						load_tables_proc = Proc.new do |data|

							@@store_definition_descriptor[:tables].each do |t_class|
								data.table t_class
							end

						end

						DROPBOX_CONTEXTS[@local_session[:dropbox_context] + "_DATA"] = DropboxStore::Data.new(
								ctx, 
								@@store_definition_descriptor[:datastore_id],
								&load_tables_proc
							)

					end

					return DROPBOX_CONTEXTS[@local_session[:dropbox_context] + "_DATA"] 
				end


			end
		end

	end

end


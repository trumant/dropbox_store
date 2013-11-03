module DropboxStore

	#
	#   Context for interaction with dropbox store
	#
	class Context
		
		attr_reader :app_key
		attr_reader :app_secret
		attr_accessor :token
		attr_accessor :auth_code
		attr_accessor :redirect_url
		attr_accessor :active_store

		#
		#  Initialize datastore context for app
		#
		def initialize(app_key, app_secret)
			@app_key = app_key
			@app_secret = app_secret
		end

	end

end
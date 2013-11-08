require 'json'
require "net/https"

require "dropbox_store/version"
require "dropbox_store/authentication"
require "dropbox_store/context"
require "dropbox_store/data"
require "dropbox_store/datastores"
require "dropbox_store/record"
require "dropbox_store/session_store"
require "dropbox_store/store"
require "dropbox_store/table"
require "dropbox_store/token_action"
require "dropbox_store/token_filter"


module DropboxStore

	# url
	API_URL = "https://api.dropbox.com/1/"

	# valid functions
	VALID_FUNCTIONS = %q{ 
		datastores/list_datastores datastores/get_datastore 
		datastores/get_or_create_datastore datastores/create_datastore datastores/delete_datastore 
		datastores/get_deltas datastores/put_delta datastores/get_snapshot datastores/await 
		oauth2/token
	}


	#
	#  POSTs a message to dropbox datastore api
	#
	def self.message(ctx, name, params = {})
		if not DropboxStore::VALID_FUNCTIONS.include? name then
			raise "function #{name} not part of dropbox datastore api services"
		end

		url = URI.parse(API_URL + name)

		# setup to do SSL request
		http = Net::HTTP.new(url.host, url.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE

		# request this one
		request = Net::HTTP::Post.new(url.path)
		request.set_form_data(params)

		# dont have a token yet?
		if ctx.token.nil? then
			request.basic_auth(ctx.app_key, ctx.app_secret) 
		else
			request['Authorization'] = "Bearer #{ctx.token}"
		end

		begin
			response = http.request(request)

			# json response?
			if response.body[0] == '{' then 
				JSON.parse(response.body) 
			else
				response.body
			end
		rescue Exception => e
			raise "Could not complete request: #{e}"
		end
	end

end

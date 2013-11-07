module DropboxStore

	#
	#  Authentication callbacks
	#
	module Authentication

		def self.cli_init
			ctx = DropboxStore::Context.new(DROPBOX_KEY, DROPBOX_SECRET)
			puts "goto: " + DropboxStore::Authentication::authorization_url(ctx)
			print "authorization code: " 
			ctx.auth_code = gets.strip
			DropboxStore::Authentication::get_token(ctx)
			ctx
		end

		def self.is_authorized?(ctx)
			return !ctx.auth_code.nil? 
		end

		#
		#   Return the authorization url we need to go to
		#
		def self.authorization_url(ctx)
			base_url = "https://www.dropbox.com/1/oauth2/authorize?client_id=%s&response_type=code" % [ctx.app_key]
			if ctx.redirect_url then
				base_url += "&redirect_uri=" + ctx.redirect_url
			end
			base_url
		end

		def self.get_token(ctx)
			msg_params = {
				grant_type: "authorization_code",
				code: ctx.auth_code
			}
			msg_params[:redirect_uri] = ctx.redirect_url if ctx.redirect_url

			result = DropboxStore::message(ctx, 'oauth2/token', msg_params)	

			if result.has_key? "access_token" then
				ctx.token = result["access_token"]
			else
				puts "RESULT: #{result}"
				raise "unable to retrieve the access token, please try again"
			end
		end

	end

end

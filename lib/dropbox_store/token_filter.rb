#
#  The token filter adds a before_filter to your rails application's
#  controller that enforces any element in that controller to have
#  session dropbox context
#
#  It expects that in some initializer the DROPBOX_KEY, DROPBOX_SECRET and
#  DROPBOX_REDIRECT_URL variables have been set.
#

module DropboxStore

	module TokenFilter

		#
		#  Filter implementation that makes sure that there is a dropbox context
		#  in the session. If it has not been authorized yet, it will redirect to the
		#  authorization url. 
		#
		def requires_token

			raise "Setup your initializers to specify DROPBOX_KEY, DROPBOX_SECRET and DROPBOX_REDIRECT_URL" unless DROPBOX_KEY and DROPBOX_SECRET and DROPBOX_REDIRECT_URL

			if not session[:dropbox_context] then
				context = DropboxStore::Context.new(DROPBOX_KEY, DROPBOX_SECRET)
				context.redirect_url = DROPBOX_REDIRECT_URL
				session[:dropbox_context] = context
			end

			ctx = session[:dropbox_context]

			# authorized yet?
			if not DropboxStore::Authentication::is_authorized?(ctx) then
				redirect_to DropboxStore::Authentication::authorization_url(ctx)
			end
		end


	end

end

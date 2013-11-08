module DropboxStore

	module TokenAction


		#
		#  Called when token redirect is complete
		#
		def get_token
			if not session[:dropbox_context] then 
				redirect_to "/"
			end

			puts "UUID: " + session[:dropbox_context]
			puts "CONTEXTS: " + DROPBOX_CONTEXTS.inspect

			ctx = DROPBOX_CONTEXTS[session[:dropbox_context]]
			ctx.auth_code = params[:code]
			ctx.token = nil
			DropboxStore::Authentication::get_token(ctx)
			
			redirect_to "/"
		end


		def logout
			DROPBOX_CONTEXTS[session[:dropbox_context]] = nil
			session[:dropbox_context] = nil
			redirect_to '/'
		end

	end

end
module DropboxStore

	module TokenAction

		#
		#  Called when token redirect is complete
		#
		def get_token
			if not session[:dropbox_context] then 
				redirect_to "/"
			end

			ctx = session[:dropbox_context]
			ctx.auth_code = params[:code]
			
			session[:dropbox_context] = ctx
			redirect_to "/"
		end

	end

end
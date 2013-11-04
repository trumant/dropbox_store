# DropboxStore

This gem does the following:

* provide an interface between your application and the Dropbox Datastore API using the HTTPS calls as they have been described here https://www.dropbox.com/developers/datastore/docs/http. It's currently a subset of all the commands as I'm not actually using all of them myself. Feel free to add to them. 

* contains a number of simple hooks you can use to make your Rails app Dropbox Datastore ready

* provide a simple wrapper over the records that will allow you to query them sort of like you would with ActiveRecord (but much more rudimentary)

## Installation

Add this line to your application's Gemfile:

    gem 'dropbox_store'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dropbox_store

## Usage

Create an initializer with the following content:

	DROPBOX_KEY = "--"
	DROPBOX_SECRET = "--"
	DROPBOX_REDIRECT_URL = "http://localhost:3000/dropbox_token"

You should probably set the redirect url depending on the environment you're running stuff on, I'll leave that up to you though.

Add the following lines to your ApplicationController:

	include DropboxStore::TokenFilter

Add to the controllers that definitely need a dropbox token the following:

	before_filter :requires_token

This adds a function to your application controller that keeps track of whether we have gotten a authorization code from Dropbox yet, if not a redirect will take place once the before_filter has been run.

Create a dropbox_controller.rb and put the following inside:

	class DropboxController < ApplicationController

		include DropboxStore::TokenAction

	end

Then add something like this to your routes.rb and have that be the redirect_url you setup in your Dropbox app settings:

	get '/dropbox_token' => "dropbox#get_token"

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

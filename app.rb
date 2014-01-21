require 'rubygems'
require 'sinatra'
require 'tumblr_client'
require 'oauth' #not needed?
require 'omniauth'
require 'omniauth-tumblr'

class SinatraApp < Sinatra::Base

	configure do
	  set :sessions, true
	  set :inline_templates, true
	end

	use OmniAuth::Strategies::Tumblr, 
	'zAYCzweMId3DonItlHd3BexfyoayCmyaxyudrk9yM72BjKUXcZ', 
	'DAUrT9gwWi7GzNgF4fkHYmD5dQVPMHwKLI8yCPlcrlDkCq7K5A'

	get '/' do
		if session[:authenticated]
	  	  erb :index
		else
			"<a href='http://localhost:4567/auth/tumblr'>Login with Tumblr</a>"
		end
	end

	get '/auth/:provider/callback' do
		session[:authenticated] = true
		# "<pre>#{JSON.pretty_generate(request.env['omniauth.auth'])}</pre>"

		auth = request.env["omniauth.auth"]
		session[:user_id] = auth["uid"]
		session[:access_token] = auth['credentials']['token']
	  session[:access_token_secret] = auth['credentials']['secret']

	  Tumblr.configure do |config|
		  config.consumer_key = "zAYCzweMId3DonItlHd3BexfyoayCmyaxyudrk9yM72BjKUXcZ"
		  config.consumer_secret = "DAUrT9gwWi7GzNgF4fkHYmD5dQVPMHwKLI8yCPlcrlDkCq7K5A"
		  config.oauth_token = session[:access_token]
		  config.oauth_token_secret = session[:access_token_secret]
		end

		@@client = Tumblr::Client.new

		redirect '/'

	end

	post '/' do

		params['myfile'].each do |file|
			type = file[:type]
		  file = file[:tempfile]
		  puts type

			if (type =~ /text/) == 0
			 	@@client.text("#{session[:user_id]}.tumblr.com", 
			 		{:body => "#{file.read.gsub!(/\r?\n/,"\n")}"})

		 elsif (type =~ /image/) == 0
			 	@@client.photo("#{session[:user_id]}.tumblr.com", 
			 		{:data => "#{file.path}"})

			else
		    "#{file} didn't/couldn't upload!" 
		 end


			

		end
			redirect "http://www.tumblr.com/mega-editor/cool-gf"
			
		# For in-browser editor:
    
    # text.each_line do |line|
			#one post per line! whatttt
		  # @@client.text("#{session[:user_id]}.tumblr.com", {:body => "#{line}"})
		# end

    end #ends post










	get '/auth/failure' do
	  "<h1>Authentication Failed:</h1><h3>message:<h3> <pre>#{params}</pre>"
	end

	get '/auth/:provider/deauthorized' do
	  "#{params[:provider]} has deauthorized this app."
	end

	get '/protected' do
	  throw(:halt, [401, "Not authorized\n"]) unless session[:authenticated]
	  "<pre>#{request.env['omniauth.auth'].to_json}</pre><hr>
	       <a href='/logout'>Logout</a>"
	end

	get '/logout' do
	  session[:authenticated] = false
	  redirect '/'
	end


end #end of SinatraApp class

SinatraApp.run!

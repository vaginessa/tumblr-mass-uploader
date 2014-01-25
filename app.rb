require 'rubygems'
require 'sinatra'
require 'tumblr_client'
require 'oauth'
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
<<<<<<< HEAD
			erb :signin
=======
			"<a href='http://fierce-ravine-5098.herokuapp.com/auth/tumblr'>Login with Tumblr</a>"
>>>>>>> 889d6fec88cd1d9681e34f42cfa766475ca735c8
		end
	end

	get '/auth/:provider/callback' do
		session[:authenticated] = true
		# puts JSON.pretty_generate(request.env['omniauth.auth'])

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
		begin
			params['myfile'].each do |file|
				type = file[:type]
				file = file[:tempfile]
				puts type

					if (type =~ /text/) == 0
						if params['blog_name'] != ""
							@@client.text("#{params['blog_name']}.tumblr.com", 
								{:body => "#{file.read.gsub!(/\r?\n/,"\n")}"})
						else #if blog name not given, use default
							@@client.text("#{session[:user_id]}.tumblr.com", 
								{:body => "#{file.read.gsub!(/\r?\n/,"\n")}"})
						end

				 elsif (type =~ /image/) == 0
						if params['blog_name'] != ""
							@@client.photo("#{params['blog_name']}.tumblr.com", 
								{:data => "#{file.path}"})
						else
							@@client.photo("#{session[:user_id]}.tumblr.com", 
								{:data => "#{file.path}"})
						end

					else
						puts "Please select at least one photo or text file!"
				 end


				

			end

		rescue NoMethodError
			puts "NoMethodError"
		end # end begin/rescue

			session[:authenticated] = false # automatically logs out on exit
			redirect "http://www.tumblr.com/mega-editor/#{params['blog_name']}"

		end










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

	not_found do
		status 404
		"not found"
	end

end

SinatraApp.run!

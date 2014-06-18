OAuth2Strategy = require('passport-oauth').OAuth2Strategy
InternalOAuthError = require('passport-oauth').InternalOAuthError
OAuth2 = require('oauth').OAuth2
fs = require 'fs'

url = 'https://ttsoon.com/org'
provider = 'ttsoon'
dir = '/etc/ssl/certs'
files = fs.readdirSync(dir).filter (file) -> /.*\.pem/i.test(file)
files = files.map (file) -> "#{dir}/#{file}"
ca = files.map (file) -> fs.readFileSync file

class OAuth2CA extends OAuth2
	constructor: (options) ->
		super(options.clientID,  options.clientSecret, options.baseSite, options.authorizationURL, options.tokenURL, options.customHeaders)
		@options = options
		@useAuthorizationHeaderforGET(true)
		
	_executeRequest: (http_library, options, post_body, callback) ->
		options.ca = @options.ca
		super(http_library, options, post_body, callback)

class Strategy extends OAuth2Strategy
	constructor: (options, verify) ->
		@options = options || {}
		@options.authorizationURL = options.authorizationURL || "#{url}/oauth2/authorize/"
		@options.tokenURL = options.tokenURL || "#{url}/oauth2/token/"
		@options.profileURL = options.profileURL || "#{url}/api/users/me/"
		@options.ca = options.ca || ca
		super(@options, verify)
		@options.baseSite = ''
		@_oauth2 = new OAuth2CA(@options)
		@name = provider
		
	userProfile: (accessToken, done) ->
		@_oauth2.get @options.profileURL, accessToken, (err, body, res) ->
			if err
				return done new InternalOAuthError('failed to fetch user profile', err)
		
			try
				json = JSON.parse(body)
				profile =
					id:				json.url
					provider:		provider
					displayName:	json.username
					emails:			[{ value: json.email }]
					_raw:			body
					_json:			json
				done(null, profile)
			catch err
				done(err)
				
module.exports = Strategy
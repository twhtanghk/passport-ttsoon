passport-ttsoon
===============

[passport](http://passportjs.org/) extension for oauth2 implicit grant with ttsoon.com

Configuration
=============


*   download server certificate into /usr/local/share/ca-certificates


    openssl s_client -showcerts -connect ttsoon.com:443 |openssl x509 >/usr/local/share/ca-certificates/ttsoon.com.crt

*   update system trusted ca-certificates


    update-ca-certificates
    
*   install passport-ttsoon as nodejs module
    
    
    npm install https://github.com/twhtanghk/passport-ttsoon.git

*   define the oauth2 strategy in server app.coffee


    bearer = require 'passport-http-bearer'
    
    dir = '/etc/ssl/certs'
    files = fs.readdirSync(dir).filter (file) -> /.*\.pem/i.test(file)
    files = files.map (file) -> "#{dir}/#{file}"
    ca = files.map (file) -> fs.readFileSync file

    passport.serializeUser (user, done) ->
    	done(null, user.id)
    	
    passport.deserializeUser (id, done) ->
    	model.User.findById id, (err, user) ->
    		done(err, user)
    
    passport.use 'bearer', new bearer.Strategy {}, (token, done) ->
    	opts = 
    		ca:		ca
    		headers:
    			Authorization:	"Bearer #{token}"
    	http.get env.oauth2.verifyURL, opts, (err, res, body) ->
    		if err?
    			logger.error err
    				
    		# check required scope authorized or not
    		scope = body.scope.split(' ')
    		result = _.intersection scope, clientEnv.oauth2.scope
    		if result.length != clientEnv.oauth2.scope.length
    			return done('Unauthorzied access', null)
    			
    		user = _.pick body.user, 'url', 'username', 'email'
    		done(err, user)
    		
    		
*   define web service api method with oauth2 bearer control in server


    @get '/api/xmpp/muc', bearer, ->
        # code to handle the api
        

*   define the service request parameters clientID, authURL, and scope in client. See also [jso](https://github.com/andreassolberg/jso) for oauth2 client


    jso_configure 
		oauth2:
			client_id:		env.oauth2.clientID
			authorization:	env.oauth2.authorizationURL
			scope:			env.oauth2.scope
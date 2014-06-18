passport-ttsoon
===============

[passport](http://passportjs.org/) extension for oauth2 authorization code with ttsoon.com

Configuration
=============


*   download server certificate into /usr/local/share/ca-certificates

```
    openssl s_client -showcerts -connect ttsoon.com:443 |openssl x509 >/usr/local/share/ca-certificates/ttsoon.com.crt
```

*   update system trusted ca-certificates

```
    update-ca-certificates
```

*   install passport-ttsoon as nodejs module
    
```    
    npm install https://github.com/twhtanghk/passport-ttsoon.git
```

*   define the oauth2 strategy in server app.coffee

```
    provider = require 'passport-ttsoon'
    
    authUrl = 'https://ttsoon.com/org'
	webUrl = 'http://localhost:3000/proj'
	env =
		oauth2:
			authorizationURL:	"#{authUrl}/oauth2/authorize/"
			tokenURL:			"#{authUrl}/oauth2/token/"
			profileURL:			"#{authUrl}/api/users/me"
			verifyURL:			"#{authUrl}/oauth2/verify/"
			callbackURL:		"#{webUrl}/auth/provider/callback"
			authURL:			"/auth/provider"
			cbURL:				"/auth/provider/callback"
			clientID:			'proj'
			clientSecret:		'password'
			scope:				[ "#{authUrl}/org/users" ]
			
    dir = '/etc/ssl/certs'
    files = fs.readdirSync(dir).filter (file) -> /.*\.pem/i.test(file)
    files = files.map (file) -> "#{dir}/#{file}"
    ca = files.map (file) -> fs.readFileSync file

    passport.serializeUser (user, done) ->
    	done(null, user.id)
    	
    passport.deserializeUser (id, done) ->
    	model.User.findById id, (err, user) ->
    		done(err, user)
    
    passport.use 'provider', new provider.Strategy env.oauth2, (token, refreshToken, profile, done) ->
		model.User.findOne(url: profile.id).exec (err, user) ->
			if err
				return done(err, null)
			done(err, user)
```    		
    		
*   define web api method with oauth2 login via authorization server

```
	ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn
	
	@get path, ensureLoggedIn(authURL), ->
		controller.File.open(@request, @response)
```        


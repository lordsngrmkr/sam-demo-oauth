# Copyright (C) 2014 TopCoder Inc., All Rights Reserved.

###
  OAuth demo application

  @author TCSASSEMBLER
  @version 1.0
  @since 1.0
  @module app
###

# 3rd party modules
async = require 'async'
express = require 'express'
open = require 'open'
program = require 'commander'
qs = require 'qs'
request = require 'request'
winston = require 'winston'

# local modules
config = require './config'

# accept custom certificates
process.env.NODE_TLS_REJECT_UNAUTHORIZED='0'

# winston logging configuration
winston.add winston.transports.File, {
  filename: 'oauth.log'
  level: 'debug'
}

# command line management
program
  .version('0.0.1')
  .option('-o, --open', 'Open web browser')
  .parse(process.argv);

# create the expressjs application
app = express()

# expressjs configuration
# sets the environment: development or production
app.set 'env', config.environment
# static pages and content
app.use express['static']("#{__dirname}/public")
# jade template engine settings
app.set 'views', "#{__dirname}/views"
app.set 'view engine', 'jade'
# add required parsers and session support
app.use express.bodyParser()
app.use express.cookieParser()
app.use express.session(
  cookie:
    maxAge: 1200000
    secure: false #change to true when using SSL
  proxy: true
  secret: 't0pc0d3r'
)

###
  GET / endpoint
  Homepage
  It contains a form to select and set a target environment
###
app.get '/', (req, res) ->
  env = config.get(req.session?.env)
  params = {
    # list of available environments
    environments: config.list()
    # current environment
    current: env.commonName
    # session data or default values
    loggedIn: req.session?.env
    domainId: req.session?.domainId || 1
    clientId: req.session?.clientId || env.clientId
    clientSecret: req.session?.clientSecret || env.clientSecret
    error: req.query.error
  }
  res.render 'home', params

###
  GET /environment/:name endpoint
  Retrieve the data for an environment
###
app.get '/environment/:name', (req, res) ->
  env = config.get(req.params.name)
  res.send 200, JSON.stringify env

###
  GET /logout endpoint
  Ends a session and goes back to the homepage
###
app.get '/logout', (req, res) ->
  # step 1: destroy the current session
  req.session.destroy()
  # step 2: redirect to home
  res.redirect '/'

###
  POST /session/set
  Sets the session values and redirect the user to the OAuth process
###
app.post '/session/set', (req, res, next) ->
  # step 1: set the session variables
  req.session.env = req.body.environment
  req.session.domainId = req.body.domainId
  req.session.clientId = req.body.clientId
  req.session.clientSecret = req.body.clientSecret

  # step 2: redirect to start the oauth process
  res.redirect '/auth/sam'

###
  GET /auth/sam endpoint
  Entry point for the validation process
###
app.get '/auth/sam', (req, res, next) ->
  # step 0: setup parameters
  env = config.get(req.session?.env)
  authorizationUrl = "#{env.samUrl}/oauth/authorize"
  # step 1: construct Url
  # first we get the client id key and value for URL
  clientId = req.session?.clientId || req.query.clientID
  # then we get the domain id
  domainId = req.session?.domainId || req.query.domainID
  # and finally create url manually to add the parameters
  params =
    response_type: 'code'
    redirect_uri: "http://#{config.host}:#{config.port}/oauth/callback"
    client_id: clientId
    apikey: clientId
    domainID: domainId
  uri = "#{authorizationUrl}?#{qs.stringify(params)}"
  # step 2: redirect to target url
  res.redirect uri

###
  GET /oauth/callback endpoint
  Callback used to obtain the token after an authorization code was validated
###
app.get '/oauth/callback', (req, res, next) ->
  # step 0: input validation
  if req.query.error
    req.session.destroy()
    res.redirect "/?error=#{req.query.error}"
    return true
  unless req.query.code
    err = new Error('Missing parameter: code is required')
    err.statusCode = 409
    return next err
  unless req.session.clientId
    err = new Error('Invalid session')
    err.statusCode = 409
    return next err
  # step 1: setup parameters
  env = config.get(req.session?.env)
  tokenUrl = "#{env.samUrl}/oauth/token"
  callbackUrl = "http://#{config.host}:#{config.port}/oauth/callback"
  postdata =
    code: req.query.code
    apikey: req.session.clientId
    client_secret: req.session.clientSecret
    client_id: req.session.clientId
    grant_type: 'authorization_code'
    redirect_uri: callbackUrl
  requestOptions =
    uri: tokenUrl
    rejectUnauthorized: false
    form: postdata
    headers:
      apikey: req.session.clientId
  # step 2: performs the call to obtain the token
  request.post requestOptions, (err, response, body) ->
    # step 2.1: if an error happened then redirect to the app_denied page
    if err or response?.statusCode > 299
      winston.error "ERROR #{err}"
      winston.debug "http response code: #{response.statusCode}"
      winston.debug "body: #{JSON.stringify(body)}"
      return res.redirect 'app_denied'
    # step 2.2: if no error happened, then we obtain the token and set it on session
    else
      winston.debug "response: #{response.statusCode}"
      winston.debug "body: #{body}"
      b = JSON.parse body
      req.session.user = b.access_token
      res.redirect '/app_authorized'

###
  GET /app_authorized endpoint
  Authorize the Oauth client and shows its data
###
app.get '/app_authorized', (req, res, next) ->
  # step 0: validate that the session is valid
  unless req.session.user
    err = new Error('Invalid session')
    err.statusCode = 409
    return next err
  # step 1: get the environment set on session
  env = config.get(req.session.env)
  # step 2: prepare the call the /me endpoint on the SAM server
  #         this uses the retrieved token
  meUrl = "#{env.samUrl}/me"
  requestOptions =
    url: meUrl
    rejectUnauthorized: false
    auth:
      bearer: "#{req.session.user}"
    headers:
      'Accept-version': '1.0.x'
      apikey: req.session.clientId
  # step 3: perform the call to /me
  request.get requestOptions, (err, response, body) ->
    # step 3.1: if an error happened then save logs and sets a message
    if err
      winston.error err
      winston.debug JSON.stringify(response)
      body = { message: 'an error ocurred while retrieving your information' }

    # step 3.2: render the authorization and data
    if typeof body is 'string'
      body = JSON.parse body
    res.render 'app_authorized', {
      token: req.session.user
      data: JSON.stringify(body, null, '\t')
    }

###
  GET /app_denied endpoint
  This is called when the server did not validate the OAuth process
  Basically it destroys an existing session and displays the page
###
app.get '/app_denied', (req, res) ->
  req.session.destroy()
  res.render 'app_denied'

###
  Port where the app will be bound
  @type {number}
###
port = config.port

# starts the server
app.listen port
winston.info "Demo app started on port #{port}"

# checks if the browser should be opened
if program.open
  console.log 'Opening web browser'
  # opens the browser and points it to the OAuth client
  open "http://#{config.host}:#{config.port}/"


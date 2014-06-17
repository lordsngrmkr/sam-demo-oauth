# Copyright (C) 2014 TopCoder Inc., All Rights Reserved.

###
  Configuration settings for OAuth app

  @author TCSASSEMBLER
  @version 1.0
  @since 1.0
  @module app
###

###
  Settings for local environment
  @type {Object}
###
local = {
  commonName: 'local'
  samUrl: 'https://localhost:5000'
  type: 'development'
  clientId: 1
  clientSecret: 'demo-secret'
}

###
  Settings for production environment
  @type {Object}
###
production = {
  commonName: 'production'
  samUrl: 'https://api.brivolabs.com'
  type: 'production'
}

###
  Settings for cs environment
  @type {Object}
###
cs = {
  commonName: 'cs'
  samUrl: 'https://brivolabs-sam-cs.herokuapp.com'
  type: 'testing'
}

###
  Settings for custom environment
  @type {Object}
###
# REMOVE THE COMMENT BLOCK BELOW TO ENABLE THIS
###
custom = {
  commonName: 'custom'
  samUrl: 'https://<HOST>:<PORT>'
  type: 'testing'
}
###

# module exports. A single method that returns the proper settings
module.exports =
  ###
    set current env to development or production
    @type {string}
  ###
  environment: 'development'
  ###
    address for this client
    @type {string}
  ###
  host: 'localhost'
  ###
    port for this client
    @type {number}
  ###
  port: 3000

  # environments
  ###
    production environment
    @type {object}
  ###
  production: production
  ###
    cs environment
    @type {object}
  ###
  cs: cs
  ###
    local environment
    @type {object}
  ###
  local: local

  ###
    Method that retrieves a list of available environments
    @returns [an array of environments]
  ###
  list: () ->
    [cs, local, production] # , custom]
  ###
    Method that returns the environment defined by the passed argument
    or the default one (production in this case) if the argument is undefined
    @returns an object containing the environment info
  ###
  get: (environment) ->
    switch environment || process.env.NODE_ENV
      when 'local' then return local
      when 'cs' then return cs
      when 'custom' then return custom
      else return production


jsDAV = require "jsDAV"
jsDAV.debugMode = true

cozy_Auth_Backend            = require './backends/auth'

jsDAVACL_PrincipalCollection = require "jsDAV/lib/DAVACL/principalCollection"
cozy_PrincipalBackend        = require './backends/principal'
principalBackend             = new cozy_PrincipalBackend
nodePrincipalCollection      = jsDAVACL_PrincipalCollection.new(principalBackend)


jsCardDAV_AddressBookRoot    = require "jsDAV/lib/CardDAV/addressBookRoot"
cozy_CardBackend             = require './backends/carddav'
carddavBackend               = new cozy_CardBackend require './models/contact'
nodeCardDAV                  = jsCardDAV_AddressBookRoot.new(principalBackend, carddavBackend)


jsCalDAV_CalendarRoot        = require "jsDAV/lib/CalDAV/calendarRoot"
cozy_CalBackend              = require './backends/caldav'
caldavBackend                = new cozy_CalBackend require './models/calendar'
nodeCalDAV                   = jsCalDAV_CalendarRoot.new(principalBackend, caldavBackend)


DAVServer = jsDAV.mount
    server: true
    standalone: false

    realm: 'jsDAV'
    mount: '/public/webdav/'

    authBackend: cozy_Auth_Backend.new()
    plugins: [
        require "jsDAV/lib/DAV/plugins/auth"
        require "jsDAV/lib/CardDAV/plugin"
        require "jsDAV/lib/CalDAV/plugin"
        require "jsDAV/lib/DAVACL/plugin"
    ]

    node: [nodePrincipalCollection, nodeCardDAV, nodeCalDAV]


express = require('express')
app = express()


app.use (err, req, res, next) ->
    if /^\/public/.test req.url
        # DAVServer reacted weirdly to /public -> /public/webdav by cozy-proxy
        req.url = req.url.replace '/public', '/public/webdav'
        DAVServer.exec req, res
    else
        DAVServer.exec req, res
        res.writeHead 404
        res.end 'NOT FOUND'


port = process.env.PORT || 9202
host = process.env.HOST || "0.0.0.0"

server.listen port, host, ->
    console.log "WebDAV server is listening on #{host}:#{port}..."

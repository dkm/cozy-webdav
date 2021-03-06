Exc       = require 'cozy-jsdav-fork/lib/shared/exceptions'
WebdavAccount = require '../models/webdavaccount'
axon = require 'axon'


handle    = (err) ->
    console.log err
    return new Exc.jsDAV_Exception err.message || err

module.exports = class CozyCardDAVBackend

    constructor: (@Contact) ->

        @getLastCtag (err, ctag) =>
            # we suppose something happened while webdav was down
            @ctag = ctag + 1
            @saveLastCtag @ctag

            onChange = =>
                @ctag = @ctag + 1
                @saveLastCtag @ctag

            # keep ctag updated
            socket = axon.socket 'sub-emitter'
            socket.connect 9105
            socket.on 'contact.*', onChange

    getLastCtag: (callback) ->
        WebdavAccount.first (err, account) ->
            callback err, account?.cardctag or 0

    saveLastCtag: (ctag, callback = ->) =>
        WebdavAccount.first (err, account) =>
            return callback err if err or not account
            account.updateAttributes cardctag: ctag, ->

    getAddressBooksForUser: (principalUri, callback) ->
        book =
            id: 'all-contacts'
            uri: 'all-contacts'
            principaluri: principalUri
            "{http://calendarserver.org/ns/}getctag": @ctag
            "{DAV:}displayname": 'Cozy Contacts'

        return callback null, [book]

    getCards: (addressbookId, callback) ->
        @Contact.all (err, contacts) ->
            return callback handle err if err

            callback null, contacts.map (contact) ->
                lastmodified: 0
                carddata:     contact.toVCF()
                uri:          contact.getURI()

    getCard: (addressBookId, cardUri, callback) ->
        @Contact.byURI cardUri, (err, contact) ->
            return callback handle err if err
            return callback null unless contact.length

            contact = contact[0]

            callback null,
                lastmodified: 0
                carddata:     contact.toVCF()
                uri:          contact.getURI()

    createCard: (addressBookId, cardUri, cardData, callback) ->
        contact = @Contact.parse(cardData)
        contact.carddavuri = cardUri
        @Contact.create contact, (err, contact) ->
            return callback handle err if err

            callback null

    updateCard: (addressBookId, cardUri, cardData, callback) ->
        @Contact.byURI cardUri, (err, contact) =>
            return callback handle err if err
            return callback handle 'Not Found' unless contact.length

            contact = contact[0]
            data = @Contact.parse(cardData)
            data.carddavuri = cardUri

            contact.updateAttributes data, (err, contact) ->
                return callback handle err if err

                callback null

    deleteCard: (addressBookId, cardUri, callback) ->

        @Contact.byURI cardUri, (err, contact) ->
            return callback handle err if err

            contact = contact[0]

            contact.destroy (err) ->
                return callback handle err if err

                callback null

# maybe generate the deps with this:
# (IE8 shims and stuff)
# https://github.com/gilbarbara/generator-web

# add these badges to NPM:
# https://github.com/PhilWaldmann/openrecord

# me encanta este modelo de visualizar:
# http://labs.voronianski.com/jquery.avgrund.js/

# this may be a better model than what I have:
# https://www.npmjs.org/package/modella
#

# class Fable
# 	->
# 		console.log "yay!"
# 	session: ->

# class Experience
# 	(doc) ->
# 		console.log "yay"

# 	get: (path) ->
# 		...

# 	set: (path, v) ->


# TODO!!!!!!!!!! - start this with the master blueprint

slice = [].slice
( ->
	'use strict'
	Foxx = require 'org/arangodb/foxx'
	ArangoDB = require "org/arangodb"
	Actions = require "org/arangodb/actions"
	DB = ArangoDB.db
	{ ArangoDatabase, ArangoCollection } = ArangoDB
	#ArangoCollection = require 'org/arangodb/arango-collection' .ArangoCollection
	internal = require 'internal'
	Da_Funk = require \./lib/da_funk
	console = require 'console'
	_ = require \lodash

	controller = new Foxx.Controller applicationContext
	BLUEPRINT_COLLECTION_NAME = applicationContext.collectionName \Blueprint

	# TODO: IMPROVE THIS... move away from Foxx.Model
	Blueprint = Foxx.Model.extend {}, {
		attributes:
			persona:
				type: \string
				required: true
				description: "the user that created this blueprint"
			encantador:
				type: \string
				required: true
				description: "the incantation of this blueprint"
			incantation:
				type: \string
				required: true
				description: "the incantation of this blueprint"
			version:
				type: \string
				required: true
				description: "the version of this blueprint"
			type:
				type: \string
				# required: true
				description: "the type of blueprint this is (Cardinal/Fixed/Mutable)"
			layout:
				type: \object
				required: true
			quests:
				type: \object
			machina:
				type: \object
				required: true
			embodies:
				type: \object
			poetry:
				type: \object
			phrases:
				type: \object
			api:
				type: \object
	}

	Blueprints_repo = Foxx.Repository.extend {
		#create / remove / etc
		all: ->
			arr = if @collection => @collection.toArray! else []
			return arr
		bp: (id) ->
			@collection.document id
	}

	path = controller.get '/_bp', (req, res) ->
		# setup.reset!
		# for bp of
		if req.params \reset
			admin.reset applicationContext
			res.json {success: true}
		else
			res.json {success: false}
	path.queryParam \reset, type: \string description: "reload the blueprints from the fs?"
	path = controller.post '/_admin/reset', (req, res) ->
		console.log "TODO: reset functionality"
		# for bp of
		res.json {success: true}

	path = controller.get '/_bp/_', (req, res) ->
		console.log "TODO: add version to the mix"
		bps = Blueprints.all!# req.user._key
		#bps.bps = _.map bps.bps, ((dd) ->
		#	console.log "got bp", dd
		#	console.dir dd
		#	dd.forClient!
		#), @
		res.json bps
	#path.onlyIfAuthenticated 401, 'not logged in'

	# OMG WTF LOLZ!! - add the da_funk stuff to arango and do all of the extension inside

	# sham love! Wow!

	# brainless but famous

	# frozen idle worshippers

	# instead of trying to be jesus, give john the baptist a go, and prepare the way

	# starting a story like a champion: sabes lo que me ha pasao?

	query = """
	FOR m IN Mun
		FILTER m.persona == @persona
		RETURN m
	"""
	mun_query = DB._createStatement query: query

	query = """
	FOR bp IN #BLUEPRINT_COLLECTION_NAME
		FILTER bp.incantation == @incantation
		FILTER bp.version == '0.1.1'
		SORT bp.version DESC
		LIMIT 1
		RETURN bp
	"""
	# FOR bp in Blueprint
	#   FILTER bp.encantador == 'Poem'
	#   FILTER bp.incantation == 'UniVerse'
	#   RETURN bp
	bps_query = DB._createStatement query: query
	query = """
	FOR bp IN #BLUEPRINT_COLLECTION_NAME
		FILTER bp.encantador == @encantador
		FILTER bp.incantation == @incantation
		SORT bp.version DESC
		LIMIT 1
		RETURN bp
	"""
	bp_query = DB._createStatement query: query

	parse_fqvn = (fqvn) ->
		if ~(idx = fqvn.indexOf ':')
			incantation = fqvn.substr idx+1
			encantador = fqvn.substr 0, idx
		else
			encantador = \Word
			incantation = fqvn

		ret = {encantador, incantation}

		if ~(idx = incantation.indexOf '@')
			ret.version = version = incantation.substr idx+1
			ret.incantation = incantation.substr 0, idx

		return ret

	get_bp = (encantador, incantation, version) ->
		if typeof encantador is \object
			{encantador, incantation, version} = encantador
		# console.log "get_bp", encantador, incantation, version
		if ~(idx = incantation.indexOf '@')
			version = incantation.substr idx+1
			incantation = incantation.substr 0, idx
		if version and version isnt \latest
			#TODO: if we have conditional semver stuff (ex: >=0.1.0) do a custom query
			# example.version = version
			bp = Blueprint_collection.byExample {encantador, incantation, version}
		else
			# console.log "running query!!", encantador, incantation#, query
			bp_query.bind \encantador, encantador
			bp_query.bind \incantation, incantation
			bp = bp_query.execute!

		# bpz = bp.next!
		return bp.next!

	do_doc = (incantation, req) ->
		console.log "incantation", incantation

		bp = Da_Funk.da_funkiest get_bp \Voice, incantation
		_doc = req.body!
		if typeof(exp = bp.experience) isnt \undefined and typeof exp.have is \function
			# Da_Funk.extend _doc, exp.have.call
			_doc <<< exp.have.call this, DB, req

		get = (path, no_default) ->
			if typeof (v = if ~path.indexOf '.' then get_path(_doc, path) else _doc[path]) is \undefined and not no_default and typeof (s = bp.layout[path]) isnt \undefined
				if typeof (v = s.default) is \function
					console.log "calling default:", s.'default.js'
					v = v.call {
						get: get
					}, s
			return v
		# d = _.cloneDeep _doc
		_.each bp.layout, (!(v, k) ->
			if v.required
				_doc[k] = get k
		) #,  #this
		console.log "doc:", JSON.stringify _doc
		return _doc


	path = controller.post '/_/:blueprint/', (req, res) !->
		blueprint = req.params(\blueprint)
		body = Actions.getJsonBody req, res
		quest = body.quest
		# if not id = req.params(\id)
		# 	res.status 404
		# 	res.json {code: \EINVALID}
		# 	return
		# encantador = req.params(\encantador)
		# version = req.params(\version)
		fqvn = parse_fqvn blueprint
		_bp = get_bp fqvn
		console.log typeof _bp, JSON.stringify fqvn
		console.log "quest:", quest
		console.log "user:", JSON.stringify req.user
		if not _bp
			res.status 402
			res.json {code: \ENOENT}
			return
		else if cid = body.cursor
			console.log "get more on cursor: #cid"
			try
				cursor = CURSOR cid
			catch e
				res.status 403
				res.json {code: \EXPIRED}
				return
		else if not _bp.quests or typeof quest isnt \string or typeof (q = _bp.quests[quest]) isnt \object
			res.status 404
			res.json {code: \ENOQUESTS}
			return
			# you requested quest: ...
			# these are the available quests: [...]
		else if q
			_q = Da_Funk.da_funk q
			# later, this is defined by the blueprint...
			if body.many
				many = body.many
				delete body.many
			else many = 10
			bindvars = (q.bindvars || {}) <<< body
			# TODO: make init functions work.
			# also, this won't work because it'll be '8' anyway... need to funkify it
			# if typeof quests.init is \function
			# 	quests.init
			# TODO: make bindvars extend existing ones...
			# bindvars = Da_Funk.extend bindvars, actions.getJsonBody(req, res), _bp.

			# delete the original request?
			console.log "body", JSON.stringify body
			# console.log "bindvars", JSON.stringify bindvars
			console.log "inquiry", q.inquiry
			console.log "q.have", typeof _q.have
			if typeof _q.have is \function
				switch typeof (ret = _q.have DB, req, res)
				| \object =>
					console.log "merging...", JSON.stringify ret
					# Da_Funk.extend bindvars, ret
					bindvars <<< ret
				# | \boolean =>
				# | otherwise =>
				# 	res.status 500
				# | \undefined => fallthrough
			delete bindvars.quest
			# if bindvars.persona or quest is 'where my dawgs at?'
			# 	bindvars.persona = '330776999'
			console.log "bindvars", JSON.stringify bindvars
			cursor = internal.AQL_QUERY q.inquiry, bindvars, count: true, batchSize: many, {}
		else
			res.status 502
			res.json {code: \ECONFUSED}

		if Array.isArray cursor
			hasCount = true #if options and options.countRequestsed then true else false
			count = cursor.length
			rows = cursor
			hasNext = false
			cursorId = null
		else if typeof cursor is \object
			if typeof cursor.getExtra isnt \undefined
				# // cursor is assumed to be an ArangoCursor
				hasCount = cursor.hasCount!
				count = cursor.count!
				rows = cursor.toArray!

				# // must come after toArray()
				hasNext = cursor.hasNext!
				extra = cursor.getExtra!

				if hasNext
					cursor.persist!
					cursorId = cursor.id!
				else
					cursorId = null
					cursor.dispose!
			else if cursor.hasOwnProperty \docs
				# // cursor is a regular JS object (performance optimisation)
				hasCount = true #if options and options.countRequestsed => true else false
				count = cursor.docs.length
				rows = cursor.docs
				extra = cursor.extra
				hasNext = false
				cursorId = null

		# // do not use cursor after this

		result =
			result: rows,
			hasMore: hasNext

		if cursorId
			result.id = cursorId

		if hasCount
			result.count = count

		if typeof extra isnt \undefined and Object.keys extra .length > 0
			result.extra = extra

		if typeof code is \undefined
			code = \created # exports.HTTP_CREATED

		res.json result

		# this supposedly runs the garbage collector.
		# perhaps I should do this from time to time...
		cursor = null
		internal.wait 0
	# path.queryParam \more, type: \number description: "get more from this query cursor"
	# path.queryParam \offset, type: \number description: "what page"
	path.pathParam \blueprint, type: \string description: "what Blueprint?"
	# path.bodyParam \quest, type: \string, description: "what quest are we doing?"
	# path.pathParam \id, type: \string description: "what query"

	path = controller.post '/_deps' (req, res) ->
		console.log "TODO: get all of the deps here... this will be an array"
		bps_query.bind \incantation, <[ProfileComments Mun]>
		bps = bp_query.execute!
		res.json bps.toArray!

	# embody_bp = (bp) ->
	# 	console.log "embody #bp", bp
	# 	unless bp
	# 		throw new Error "can't extend empty bp #bp"
	# 	embody_bps = []
	# 	embody_bp_ = []
	# 	# this needs to be recursive!

	# 	# why sdo I do this?
	# 	embodies = if bp.encantador is bp.incantation then bp.embodies else [ bp.incantation ]
	# 	if typeof embodies is \string
	# 		embodies = [embodies]
	# 	if _.isArray embodies and embodies.length
	# 		while embodied_bp = embodies.shift!
	# 			bpz = get_bp bp.encantador, embodied_bp
	# 			# if bpz
	# 			if (eb = bpz.embodies)
	# 				for incantation in (if typeof eb is \string => [eb] else eb)
	# 					if not ~embody_bp_.indexOf incantation
	# 						embodies.unshift incantation
	# 				embody_bps.push bpz
	# 				embody_bp_.push bpz.incantation

	# 		console.log "embodying #{bp.incantation} with...", embody_bp_.join ','

	# 		embody_bps.unshift get_bp bp.encantador, bp.encantador
	# 		embody_bp_.unshift bp.encantador
	# 		embody_bps.unshift bp
	# 		embody_bp_.unshift bp.incantation
	# 		Da_Funk.embody.apply this, embody_bps
	# 	else bp

	path = controller.get '/_bp/:encantador/:incantation' (req, res) ->
		console.log "get_bp", req.params(\encantador), req.params(\incantation), req.params(\version)
		if b = get_bp req.params(\encantador), req.params(\incantation), req.params(\version)
			res.json b
		else
			res.status 404
			res.json code: \ENOENT
	path.pathParam \encantador, type: \string description: "what is the encantador (the machina which gives this life) of this blueprint"
	path.pathParam \incantation, type: \string description: "what is the name (incantation) of this blueprint"
	path.queryParam \version, type: \string description: "what id you want to get"
	#path.onlyIfAuthenticated 401, 'not logged in'

	path = controller.del '/_bp/:id' (req, res) ->
		bp = Blueprint.removeById req.params \id
	path.pathParam \id, type: \string description: "what id you want to delete"
	path.onlyIfAuthenticated 401, 'not logged in'

	path = controller.patch '/_bp/:id' (req, res) ->
		bps.removeById req.params \id
		res.json bp.forClient!
	path.pathParam \id, type: \string description: "what id you want to get"
	path.bodyParam \data, "new data for your Blueprint" , Blueprint
	path.onlyIfAuthenticated 401, 'not logged in'

	# path = controller.put '/_bp', (req, res) ->
	# 	bp = new Blueprint req.body!
	# 	res.json Blueprints.save bp
	# path.bodyParam \incantation, "the incantation of your Blueprint", Blueprint
	# path.bodyParam \encantador, "the incantation of your Blueprint", Blueprint
	# path.bodyParam \persona, "the owner of this Blueprint", Blueprint
	# path.onlyIfAuthenticated 401, 'not logged in'

	#TODO: need to make sure different versions of the same bp have ciertas versions
	set_paths = []

	# TODO: when a blueprint is updated, I need to add the path if it doesn't already exist...
	_.each Blueprints.all!, (bp) ->
		_bp = Da_Funk.da_funk bp
		incantation = _bp.incantation
		encantador = _bp.encantador
		# TODO: if the bp is global, then do this, otherwise make it poem specific
		#  ... meaning, I need a way to define per-PublicDB collections
		if _bp.type is \Fixed and _bp.presence isnt \Abstract and not collection = controller.collection incantation
			console.log "creating collection for: #{bp.encantador}/#{bp.incantation}", incantation
			try
				collection = controller.collection incantation
			catch e
				collection = DB._create applicationContext.collectionName incantation
		if layout = _bp.layout and not ~set_paths.indexOf incantation
			set_paths.push incantation
			model = Foxx.Model.extend {}, _bp.layout

			console.log "setting path: /#incantation/:id"
			path = controller.get "/#incantation/:id" (req, res) ->
				console.log "got path", req.url
				# console.log "looking for", incantation+'/'+req.params(\id)
				try
					doc = controller.document incantation+'/'+req.params(\id)
				catch e
					res.status 404
					res.json {code: \ENOENT}
				res.json doc
			path.pathParam \id, type: \string description: "what id you want to get"
			#path.onlyIfAuthenticated 401, 'not logged in'

			path = controller.del "/#incantation/:id" (req, res) ->
				id = req.params(\id)
				console.log "deleting: #id"
				res.json controller.remove incantation+'/'+id
				# console.log "remove #incantation:", bp
				#res.json bp.forClient!
			path.pathParam \id, type: \string description: "what id you want to delete"
			#path.onlyIfAuthenticated 401, 'not logged in'

			path = controller.patch "/#incantation/:id" (req, res) ->
				res.json controller.update incantation+'/'+req.params(\id)
			path.pathParam \id, type: \string description: "what id you want to get"
			path.bodyParam \data, "new data for your Blueprint", Blueprint
			#path.onlyIfAuthenticated 401, 'not logged in'

			path = controller.post "/#incantation" (req, res) ->
				doc = do_doc incantation, req
				r = collection.save doc
				console.log "saving #incantation -> #{r._key}"
				res.json r # {_rev: r._rev, _key: r._key}

			path = controller.put "/#incantation" (req, res) ->
				doc = do_doc incantation, req
				# I'm not 100% convinced this is working...
				console.log "replace #incantation -> #{doc._key}"
				res.json controller.replace incantation+'/'+req.params(\id), req.body!

			# for f in _bp.layout
			# 	path.bodyParam
			path.bodyParam \incantation, "the incantation of your Blueprint", Blueprint
			path.bodyParam \persona, "the owner of this Blueprint", Blueprint

		if typeof _bp.api is \function
			api = {}
			# _.each <[get del delete put post patch head before after]>, (method) ->
			for method in <[get del delete put post patch head before after]>
				api[method] = (path, cb) ->
					app[method].call this, '/'+incantation+path, cb
			_bp.api.call bp, api, app

	# ------------------------------

	MUN_COLLECTION_NAME = applicationContext.collectionName \Mun
	Mun = Foxx.Model.extend {}, {
		attributes:
			persona:
				type: \string
				required: true
			incantation:
				type: \string
				required: true
			foto:
				type: \string
			active:
				type: \boolean
				defaultValue: true
	}
	Muns_repo = Foxx.Repository.extend {
		#create / remove / etc
		all: (persona) ->
			#_.map @collection.toArray!, ((dd) ->
			#console.log "finding all muns with uid:", uid
			qry = @collection.byExample {uid}
			muns: qry.toArray!
			#muns: _.map qry.toArray!, (dd) ->
				#console.log "mun:", dd
				#return new @modelPrototype dd
			#	return dd
			count: qry.count!
	}
	# Muns = new Muns_repo controller.collection(\Mun), model: Mun



	path = controller.get '/mun/_', (req, res) ->
		muns = Muns.all req.user._key
		#muns.muns = _.map muns.muns, ((dd) ->
		#	console.log "got mun", dd
		#	console.dir dd
		#	dd.forClient!
		#), @
		res.json muns
	path.onlyIfAuthenticated 401, 'not logged in'

	path = controller.get '/mun/:id' (req, res) ->
		mun = Mun.byId req.params \id
		res.json mun.forClient!
	path.pathParam \id, type: \string description: "what id you want to get"
	path.onlyIfAuthenticated 401, 'not logged in'

	path = controller.get '/mun/:id' (req, res) ->
		mun = Mun.byId req.params \id
		res.json mun.forClient!
	path.pathParam \id, type: \string description: "what id you want to get"
	path.onlyIfAuthenticated 401, 'not logged in'

	path = controller.del '/mun/:id' (req, res) ->
		mun = Mun.removeById req.params \id
		console.log "remove mun:", mun
		#res.json mun.forClient!
	path.pathParam \id, type: \string description: "what id you want to get"
	path.onlyIfAuthenticated 401, 'not logged in'

	path = controller.patch '/mun/:id' (req, res) ->
		muns.removeById req.params \id
		res.json mun.forClient!
	path.pathParam \id, type: \string description: "what id you want to get"
	path.bodyParam \incantation, "new incantation for your Mun", Mun
	path.onlyIfAuthenticated 401, 'not logged in'

	path = controller.put '/mun', (req, res) ->
		mun = new Mun req.body!
		res.json Muns.save mun
	path.bodyParam \incantation, "the incantation of your Mun", Mun
	path.bodyParam \uid, "the owner of this Mun", Mun
	path.onlyIfAuthenticated 401, 'not logged in'

	NoAdmin = ->
	userIsAdmin = (req) ->
		if not (req.user and req.user.data.admin)
			throw new NoAdmin

	NoAdmin.prototype = new Error
	controller.activateAuthentication {
		type: 'cookie'
		cookieName: 'sessid'
		cookieLifetime: 360000
		sessionLifetime: 600
	}

	controller.login '/login', {
		onSuccess: (req, res) ->
			req.currentSession.set 'poem', 'Affinaty'
			console.log "login mun:", req.user.data.mun, req.user._key
			if not (mid = req.user.data.mun) and mun = Mun_collection.firstExample {uid: req.user._key}
				console.log "finding a mun:"
				console.dir mun
				req.currentSession.set \mun, mid = mun._key
			res.json {
				msg: 'Logged in!'
				ident: req.user.identifier
				persona: req.user._key
				key: req.currentSession._key
				now: req.currentSession.data
				mun: mun
				# poem: req.currentSession.data.poem
			}
		}

	# set active mun
	path = controller.post '/whoami' (req, res) ->
		console.log "WHOAMI", req.body!mun
		if mun = Mun_collection.firstExample {persona: req.user._key, _key: req.body!mun}
			console.log "found!", mun._key
			req.currentSession.set \mun, mid = mun._key
			# req.currentSession.save!
		res.json req.currentSession.data
	path.onlyIfAuthenticated 401, 'not logged in'
	# path.bodyParam \mun, "the owner of this Mun"

	# logout path
	controller.logout '/logout'

	# whoami / me
	path = controller.get '/whoami', (req, res) ->
		res.json {
			ident: req.user.identifier
			persona: req.user._key
			key: req.currentSession._key
			now: req.currentSession.data
			# mun: req.currentSession.data.mun
			# poem: req.currentSession.data.poem || \affinaty
		}
	path.onlyIfAuthenticated 401, 'not logged in'



	controller.register '/register', {
		acceptedAttributes: <[incantation full_incantation]>
		defaultAttributes: {
			admin: false
			poem: \affinaty
		}
		onSuccess: (req, res) ->
			console.log "trying to register"
			if not (mid = req.user.data.mun) and mun = Mun_collection.firstExample {uid: req.user._key}
				console.log "finding a mun:"
				console.dir mun
				req.currentSession.set \mun, mid = mun._key
			res.json {
				ident: req.user.identifier
				persona: req.user._key
				key: req.currentSession._key
				now: req.currentSession.data
				mun: req.currentSession.data.mun
				# poem: req.currentSession.data.poem
			}
		# TODO: auto add a mun
	}

	console.log "mounted paths #{applicationContext.foxxes}"

	# path = controller.get '/uV', (req, res) ->

)!

/*
PublicDB TODO list
 - add option to resolve the deps here
 -
*/

# if we are all gods and infinte creators, wouldn't seem natural for everyone to try and figure out the laws of nature and natural creation? wouldn't that be a welcome addition to your analogical mind, the great measurer and dimensioner. the architect would dimension the natural laws perfectly. the nature watcher can just stand around and watch, but to be critical, but to encourage
# therefore, encourage yourself. when you love someone dearly, you will give to them the best you can within limitations, whether monetary or conceptually. so then, you who loves yourself, wouldn't you want to give yourself an understanding of the natural part of creation. it is a mystery and difficult to notice, partly because it appears natural to the eyes, and true beauty is found only witin the creation. whether it be -- the simplicity of the creation, the appearance of effortlessness througout -- or any of the other virtues manifested, beauty is recognized for its natural appearance

DEBUG = true

( ->
	'use strict'
	Foxx = require 'org/arangodb/foxx'
	Auth = require \org/arangodb/foxx/authentication
	ArangoDB = require "org/arangodb"
	Actions = require "org/arangodb/actions"
	DB = ArangoDB.db
	{ ArangoDatabase, ArangoCollection } = ArangoDB
	#ArangoCollection = require 'org/arangodb/arango-collection' .ArangoCollection
	internal = require 'internal'
	Fs = require \fs
	Path = require \path
	Uuid = require \node-uuid
	Da_Funk = require \./lib/da_funk
	console = require 'console'
	_ = require \lodash
	# reset = require './lib/reset' .reset

	# unless Blueprint_collection = DB._collection BLUEPRINT_COLLECTION
	# 	Blueprint_collection = DB._create BLUEPRINT_COLLECTION


	console.log "RUNNING SETUP"
	BLUEPRINT_COLLECTION_NAME = applicationContext.collectionName \Blueprint
	Blueprint_collection = DB._collection BLUEPRINT_COLLECTION_NAME
	if Blueprint_collection is null
		DB._create BLUEPRINT_COLLECTION_NAME
		Blueprint_collection = DB._collection BLUEPRINT_COLLECTION_NAME

	MUN_COLLECTION_NAME = applicationContext.collectionName \Mun
	Mun_collection = DB._collection MUN_COLLECTION_NAME
	if Mun_collection is null
		DB._create MUN_COLLECTION_NAME
		Mun_collection = DB._collection MUN_COLLECTION_NAME


	# controller = new Foxx.Controller applicationContext
	users = new Auth.Users applicationContext
	users.setup {journalSize: 1 * 0x400 * 0x400}
	users.add 'admin', 'secret', true, {
		name: 'Root'
		#admin: true
	}
	# TODO: move this over to some sort of setting to make a sandbox
	for user in <[duralog hamsternipples kenny heavyk]>
		users.add user, 'lala', true, {
			name: user
			#admin: true
		}


	s = new Auth.Sessions applicationContext
	s.setup!
	# reset!
	# ArangoCollection = require "org/arangodb" .ArangoCollection
	# session stuff....

	users = new Auth.Users applicationContext
	users.setup {journalSize: 1 * 0x400 * 0x400}
	users.add 'admin', 'secret', true, {
		name: 'Root'
		#admin: true
	}

	# init collections
	MUN_COLLECTION = applicationContext.collectionName \Mun
	Mun_collection = DB._collection MUN_COLLECTION
	if Mun_collection is null
		DB._create MUN_COLLECTION
		Mun_collection = DB._collection MUN_COLLECTION

	BLUEPRINT_COLLECTION = applicationContext.collectionName \Blueprint
	Blueprint_collection = DB._collection BLUEPRINT_COLLECTION
	if Blueprint_collection is null
		DB._create BLUEPRINT_COLLECTION
		Blueprint_collection = DB._collection BLUEPRINT_COLLECTION

	# TODO: move this over to some sort of setting to make a sandbox
	for user in <[duralog hamsternipples kenny heavyk]>
		users.add user, 'lala', true, {
			name: user
			#admin: true
		}

	# load up each of the blueprints
	blueprints = {}
	collections = {}
	models = {}
	repos = {}
	empty = []
	db_dir = Path.join \.. \uV \Blueshift \lib \db
	bp_dir = Path.join \.. \uV \Blueshift \lib \Blueprints
	_.each (f = Fs.list '.'), (file) ->
		console.log "f: #file"
	# 1. read /library
	f = Fs.list bp_dir
	for f in Fs.list bp_dir
		path = Path.join bp_dir, f
		i = f.lastIndexOf '.'
		incantation = f.substr 0, i
		if (ext = f.substr i) is \.blueprint
			contents = ''+Fs.read path
			console.log "reading '#path' ..."
			json = JSON.parse contents
			# for k,v of json
			# 	console.log "k:#k", v
			if json.incantation
				incantation = json.incantation
			else
				json.incantation = incantation
				console.warn "blueprint (#incantation) does not have a incantation. using '#incantation' as default"
			if not json.version
				console.warn "blueprint (#incantation) does not have a version. using '0.0.1' as default"
				json.version = '0.0.1'
			if not encantador = json.encantador
				console.warn "blueprint (#incantation) does not have a encantador. using 'Word' as default"
				encantador = json.encantador = \Word
			#if typeof (dependencies = json.dependencies) isnt \object
			#	json.dependencies = {}

			_bp = {}
			unless obj = Da_Funk.da_funk _.cloneDeep json
				throw new Error "could not funkify!"

			fields =
				* \encantador
				* \incantation
				* \version
				* \layout
				* \embodies
				* \elements
				* \machina
				* \phrases
				* \api
				* \uid
			extensions = <[js ls coffee]>
			# if json.abstract
			# 	if json.layout
			# 		console.warn "blueprint (#incantation) is abstract, but has a layout"
			# 	if json.fsm
			# 		console.warn "blueprint (#incantation) is abstract, but has a fsm section"
			# 	if typeof obj.instantiate isnt \function
			# 		console.warn "blueprint (#incantation) is abstract, but does not have an instantiate function"
			# 	else
			# 		fields.push \instantiate
			# else
			# 	fields.push \machina
			if json.layout and not json.abstract
				# collection_name =
				console.log "creating collection '#incantation'"
				unless collection = DB._collection incantation
					console.info "collection '#incantation' does not exist"
					empty.push incantation
					DB._create incantation
					collection = DB._collection incantation
				# for testing...
				if DEBUG and not ~empty.indexOf incantation
					empty.push incantation
				collections[incantation] = collection

				#TODO: fix up the models and get the correct abstraction going
				model = Foxx.Model.extend {}, attributes: {incantation:{type:\string}}#obj.schema
				# model = Foxx.Model.extend {}, attributes: obj.layout
				Repo = Foxx.Repository.extend {
					#create / remove / etc
					all: ->
						@collection.toArray!
					bp: (id) ->
						@collection.document id
				}
				#console.log 'db_dir', db_dir, 'incantation', incantation
				for d in Fs.list ddir = Path.join db_dir, incantation
					console.log "d:", d
					dpath = Path.join ddir, d
					contents = ''+Fs.read dpath
					console.log "reading '#path' ...", Path.basename d
					data_json = JSON.parse contents
					if ~(i = d.lastIndexOf '.')
						key = d.substr 0, i
						console.log "key:", key
						unless data_json._key
							data_json._key = key
					console.log "data file:", dpath
					if (qry = collection.byExample {data_json._key}) and count = qry.count!
						# console.log "found #count alike blueprints"
						# console.log "(setup) login.render:", if data_json.fsm and data_json.fsm.states and data_json.fsm.states.login then data_json.fsm.states.login.render else "nope!"
						doc = qry.next!
						DB._replace doc._id, data_json
						#Blueprint_collection.update doc._id, _bp
						console.log "updating!", data_json._id
					else
						#TODO: update the blueprint file with the _key
						console.log "found no similar blueprints... making new"
						console.log "contents:", contents
						collection.save data_json
				repo = new Repo collection, model: model
				#TODO: make sure all dependencies exist
				#TODO: optimize the blueprint here...
				#  1. remove the renderers not used
				#  2. remove the deps not used
				#  3. etc.
				#TODO: also have a function a la 'el_ada' which parses the source file and sticks in the LiveScript/coffee-script/etc. to allow for people to have teir own versions of the code
				# 1. later, do this automatically with the AST of livescript and add in the ability to patch it (falafel or whatever)
				# 2. even later, add this functionality into Laboratory
				#TODO: precalculate the blueprint with extensions and propare precompiled packages (which contain all of the blueprints necessary)
				#TODO: later add the ability to save the instantiation as an abstract bp (when real-time editing is ready)
				repos[incantation] = repo

			blueprints[incantation] = obj
			for k in fields
				if typeof (v = json[k]) isnt \undefined
					_bp[k] = v
				for ex in extensions
					kex = k+'.'+ex
					if typeof (v = json[kex]) isnt \undefined
						_bp[kex] = v

			if (qry = Blueprint_collection.byExample {incantation, json.version, json.encantador}) and count = qry.count!
				doc = qry.next!
				DB._replace doc._id, _bp
				console.log "updating!", doc.encantador+'/'+doc.incantation, _bp.machina
			else
				#TODO: update the blueprint file with the _key
				console.log "found no similar blueprints... making new"
				Blueprint_collection.save Da_Funk.extend {
					_key: Uuid.v4! # cchange this over to a (ppcoin) address
					uid: 0
				}, _bp


	# words = Fs.read require \word-list .split '\n'
	# for incantation, i in empty
	# 	bp = blueprints[incantation]
	# 	if typeof (reset = bp.reset) is \function
	# 		reset.call {
	# 			random-word: ->
	# 				words[parseInt(Math.random!*(words.length-1), 10)]
	# 			DB: DB
	# 			users: users
	# 			collection: collections[incantation]
	# 			blueprints: repos
	# 		}


	for incantation in empty
		bp = blueprints[incantation]

		console.log "performing empty func on #incantation"
		collection = DB._collection incantation
)!
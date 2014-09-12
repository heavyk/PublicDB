# da_funk

# I like the get/set functionality of this
# https://www.npmjs.org/package/ooze


/*
# TODO: move this over to the MachineShop and then use this as a test
obj1 =
	lala:
		field1: "obj1.field1"
		field2: "obj1.field2"

obj2 =
	lala:
		field2: "obj2.field2"
		field3: "obj2.field3"

obj3 =
	lala:
		field3: "obj3.field3"

console.log "extended:", extend_deps obj1, obj2, obj3
*/

_ = require \lodash
if typeof console is \undefined
	console = require \console

regex_space = new RegExp ' ', \g

export da_funkiest = (obj) ->
	da_funk ({} <<< obj), true

export da_funk = (obj, go_deep) ->
	for k in (keys = Object.keys obj)
		v = obj[k]
		# I choose 8 because it's unlikely that an unintended value will be of value '8'
		# it takes up only one byte, and it looks like infinaty
		# it could be any number though...
		if v is 8 and typeof (fn = obj[k+'.js']) is \string
			i = fn.indexOf '('
			ii = fn.indexOf ')'
			j = fn.indexOf '{'
			jj = fn.lastIndexOf '}'
			args = fn.substring(++i, ii).replace(regex_space, '')
			# body = fn.substring(++j, jj).trim!
			body = '"use strict"\n' + fn.substring(++j, jj).trim!
			# console.log ":args:", args
			# console.log ":body:", body
			# console.log ":orig:", fn
			# console.log "'#body'"
			# console.log "fn:", k
			obj[k] = new Function(args, body)
			#delete obj[k+'.js']
		else if _.isObject v
			if go_deep
				obj[k] = da_funk ({} <<< obj[k])
			else
				da_funk obj[k]
	obj

export objectify = (str) ->
	if str.0 is '/' or str.0 is '.'
		str = ToolShed.readFile str

	if typeof str is \string
		str = JSON.parse str
		# console.log "parsed:", str
	# else console.log "not parsing", typeof str, str
	da_funk str

export merge = (a, b) ->
	keys = _.union Object.keys(a), Object.keys(b)
	r = {}
	for k in keys
		v = b[k]
		c = a[k]

		r[k] = \
		if _.isArray c
			if _.isArray v => _.union v, c
			else if v => c ++ v
			else c
		else if _.isObject(v) and _.isObject(c) => merge c, v
		else if typeof c is \undefined => v
		else c
	return r

export extend = (a, b) ->
	keys = _.union Object.keys(a), Object.keys(b)
	for k in keys
		v = b[k]
		c = a[k]
		a[k] = \
		if _.isArray c
			if _.isArray v
				_.union v, c
			else if v
				c ++ v
			else c
		else if _.isObject(v) and _.isObject(c)
			extend c, v
		else v || c
	return a


export embody = (obj) ->
	deps = {}
	i = &.length
	while i-- > 1
		if _.isObject a = &[i]
			#console.log deps.name, "<<<", a.name, if a.fsm then a.fsm.renderers else "nope!"
			deps = extend deps, a
	console.log "(extend.before) bp.renderers:", if deps.fsm then deps.fsm.renderers else "nope!"
	console.log "(extend.before) login.render:", if deps.fsm and deps.fsm.states and deps.fsm.states.login then deps.fsm.states.login.render else "nope!"
	deps = merge obj, deps
	console.log "(extend.after) bp.renderers:", if deps.fsm then deps.fsm.renderers else "nope!"
	console.log "(extend.after) login.render:", if deps.fsm and deps.fsm.states and deps.fsm.states.login then deps.fsm.states.login.render else "nope!"
	return deps

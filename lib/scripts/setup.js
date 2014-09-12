// Generated by LiveScript 1.2.0
/*
PublicDB TODO list
 - add option to resolve the deps here
 -
*/
var DEBUG;
DEBUG = true;
(function(){
  'use strict';
  var Foxx, Auth, ArangoDB, Actions, DB, ArangoDatabase, ArangoCollection, internal, Fs, Path, Uuid, Da_Funk, console, _, BLUEPRINT_COLLECTION_NAME, Blueprint_collection, MUN_COLLECTION_NAME, Mun_collection, users, i$, ref$, len$, user, s, MUN_COLLECTION, BLUEPRINT_COLLECTION, blueprints, collections, models, repos, empty, db_dir, bp_dir, f, path, i, incantation, ext, contents, json, encantador, _bp, obj, fields, extensions, collection, model, Repo, j$, ref1$, ddir, len1$, d, dpath, data_json, key, qry, count, doc, repo, k, v, k$, len2$, ex, kex, bp, results$ = [];
  Foxx = require('org/arangodb/foxx');
  Auth = require('org/arangodb/foxx/authentication');
  ArangoDB = require("org/arangodb");
  Actions = require("org/arangodb/actions");
  DB = ArangoDB.db;
  ArangoDatabase = ArangoDB.ArangoDatabase, ArangoCollection = ArangoDB.ArangoCollection;
  internal = require('internal');
  Fs = require('fs');
  Path = require('path');
  Uuid = require('node-uuid');
  Da_Funk = require('./lib/da_funk');
  console = require('console');
  _ = require('lodash');
  console.log("RUNNING SETUP");
  BLUEPRINT_COLLECTION_NAME = applicationContext.collectionName('Blueprint');
  Blueprint_collection = DB._collection(BLUEPRINT_COLLECTION_NAME);
  if (Blueprint_collection === null) {
    DB._create(BLUEPRINT_COLLECTION_NAME);
    Blueprint_collection = DB._collection(BLUEPRINT_COLLECTION_NAME);
  }
  MUN_COLLECTION_NAME = applicationContext.collectionName('Mun');
  Mun_collection = DB._collection(MUN_COLLECTION_NAME);
  if (Mun_collection === null) {
    DB._create(MUN_COLLECTION_NAME);
    Mun_collection = DB._collection(MUN_COLLECTION_NAME);
  }
  users = new Auth.Users(applicationContext);
  users.setup({
    journalSize: 1 * 0x400 * 0x400
  });
  users.add('admin', 'secret', true, {
    name: 'Root'
  });
  for (i$ = 0, len$ = (ref$ = ['duralog', 'hamsternipples', 'kenny', 'heavyk']).length; i$ < len$; ++i$) {
    user = ref$[i$];
    users.add(user, 'lala', true, {
      name: user
    });
  }
  s = new Auth.Sessions(applicationContext);
  s.setup();
  users = new Auth.Users(applicationContext);
  users.setup({
    journalSize: 1 * 0x400 * 0x400
  });
  users.add('admin', 'secret', true, {
    name: 'Root'
  });
  MUN_COLLECTION = applicationContext.collectionName('Mun');
  Mun_collection = DB._collection(MUN_COLLECTION);
  if (Mun_collection === null) {
    DB._create(MUN_COLLECTION);
    Mun_collection = DB._collection(MUN_COLLECTION);
  }
  BLUEPRINT_COLLECTION = applicationContext.collectionName('Blueprint');
  Blueprint_collection = DB._collection(BLUEPRINT_COLLECTION);
  if (Blueprint_collection === null) {
    DB._create(BLUEPRINT_COLLECTION);
    Blueprint_collection = DB._collection(BLUEPRINT_COLLECTION);
  }
  for (i$ = 0, len$ = (ref$ = ['duralog', 'hamsternipples', 'kenny', 'heavyk']).length; i$ < len$; ++i$) {
    user = ref$[i$];
    users.add(user, 'lala', true, {
      name: user
    });
  }
  blueprints = {};
  collections = {};
  models = {};
  repos = {};
  empty = [];
  db_dir = Path.join('..', 'uV', 'Blueshift', 'lib', 'db');
  bp_dir = Path.join('..', 'uV', 'Blueshift', 'lib', 'Blueprints');
  _.each(f = Fs.list('.'), function(file){
    return console.log("f: " + file);
  });
  f = Fs.list(bp_dir);
  for (i$ = 0, len$ = (ref$ = Fs.list(bp_dir)).length; i$ < len$; ++i$) {
    f = ref$[i$];
    path = Path.join(bp_dir, f);
    i = f.lastIndexOf('.');
    incantation = f.substr(0, i);
    if ((ext = f.substr(i)) === '.blueprint') {
      contents = '' + Fs.read(path);
      console.log("reading '" + path + "' ...");
      json = JSON.parse(contents);
      if (json.incantation) {
        incantation = json.incantation;
      } else {
        json.incantation = incantation;
        console.warn("blueprint (" + incantation + ") does not have a incantation. using '" + incantation + "' as default");
      }
      if (!json.version) {
        console.warn("blueprint (" + incantation + ") does not have a version. using '0.0.1' as default");
        json.version = '0.0.1';
      }
      if (!(encantador = json.encantador)) {
        console.warn("blueprint (" + incantation + ") does not have a encantador. using 'Word' as default");
        encantador = json.encantador = 'Word';
      }
      _bp = {};
      if (!(obj = Da_Funk.da_funk(_.cloneDeep(json)))) {
        throw new Error("could not funkify!");
      }
      fields = ['encantador', 'incantation', 'version', 'layout', 'embodies', 'elements', 'machina', 'phrases', 'api', 'uid'];
      extensions = ['js', 'ls', 'coffee'];
      if (json.layout && !json.abstract) {
        console.log("creating collection '" + incantation + "'");
        if (!(collection = DB._collection(incantation))) {
          console.info("collection '" + incantation + "' does not exist");
          empty.push(incantation);
          DB._create(incantation);
          collection = DB._collection(incantation);
        }
        if (DEBUG && !~empty.indexOf(incantation)) {
          empty.push(incantation);
        }
        collections[incantation] = collection;
        model = Foxx.Model.extend({}, {
          attributes: {
            incantation: {
              type: 'string'
            }
          }
        });
        Repo = Foxx.Repository.extend({
          all: fn$,
          bp: fn1$
        });
        for (j$ = 0, len1$ = (ref1$ = Fs.list(ddir = Path.join(db_dir, incantation))).length; j$ < len1$; ++j$) {
          d = ref1$[j$];
          console.log("d:", d);
          dpath = Path.join(ddir, d);
          contents = '' + Fs.read(dpath);
          console.log("reading '" + path + "' ...", Path.basename(d));
          data_json = JSON.parse(contents);
          if (~(i = d.lastIndexOf('.'))) {
            key = d.substr(0, i);
            console.log("key:", key);
            if (!data_json._key) {
              data_json._key = key;
            }
          }
          console.log("data file:", dpath);
          if ((qry = collection.byExample({
            _key: data_json._key
          })) && (count = qry.count())) {
            doc = qry.next();
            DB._replace(doc._id, data_json);
            console.log("updating!", data_json._id);
          } else {
            console.log("found no similar blueprints... making new");
            console.log("contents:", contents);
            collection.save(data_json);
          }
        }
        repo = new Repo(collection, {
          model: model
        });
        repos[incantation] = repo;
      }
      blueprints[incantation] = obj;
      for (j$ = 0, len1$ = fields.length; j$ < len1$; ++j$) {
        k = fields[j$];
        if (typeof (v = json[k]) !== 'undefined') {
          _bp[k] = v;
        }
        for (k$ = 0, len2$ = extensions.length; k$ < len2$; ++k$) {
          ex = extensions[k$];
          kex = k + '.' + ex;
          if (typeof (v = json[kex]) !== 'undefined') {
            _bp[kex] = v;
          }
        }
      }
      if ((qry = Blueprint_collection.byExample({
        incantation: incantation,
        version: json.version,
        encantador: json.encantador
      })) && (count = qry.count())) {
        doc = qry.next();
        DB._replace(doc._id, _bp);
        console.log("updating!", doc.encantador + '/' + doc.incantation, _bp.machina);
      } else {
        console.log("found no similar blueprints... making new");
        Blueprint_collection.save(Da_Funk.extend({
          _key: Uuid.v4(),
          uid: 0
        }, _bp));
      }
    }
  }
  for (i$ = 0, len$ = empty.length; i$ < len$; ++i$) {
    incantation = empty[i$];
    bp = blueprints[incantation];
    console.log("performing empty func on " + incantation);
    results$.push(collection = DB._collection(incantation));
  }
  return results$;
  function fn$(){
    return this.collection.toArray();
  }
  function fn1$(id){
    return this.collection.document(id);
  }
})();
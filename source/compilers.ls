require! './config': C
require! fs
require(\ansicolor).nice
log = (require 'ololog').configure {+tag, -locate}
require! jstransformer

trns = {styl: \stylus, sass: \sass, scss: \scss}
   |> map (k) -> ->
      jstransformer require "jstransformer-#{k}"
      .renderAsync &0, {filename: &1}
      .then prop \body

render = (compiler, text, options = {}, locals = {}) ->
   jstransformer require "jstransformer-#compiler"
   .renderAsync text, options, locals
   .then prop \body

#--------------------------------------------
filters =
   markdown: ->
      md.render &0

md = require('markdown-it')({+html})
C.'markdown-it-plugins' |> toPairs >> forEach ->
    if it.1
      try
         md.use (require resolve it.0), it.1
      catch
         log.error 'Missing module.'
         log 'Install', it.0.lightGreen
         process.exit 1

#--------------------------------------------
function resolve module
   local = process.cwd! + '/node_modules/' + module

   if fs.existsSync local
      then local
      else module

#--------------------------------------------
formats = 
   js:
      ls: ->
         render \livescript, &0, {filename: &1, ...&2}

   css: trns

   html:
      md: ->
         md.render &0
      pug: ->
         render \pug, &0, {filters, filename: &1}, &2
         # pug.render &0, {filters, filename: &1, ...&2}
      njk: ->
         render \nunjucks, &0, {filters, filename: &1}, &2

#--------------------------------------------
compile = (dst, src, text, filename, vars) ->
   if dst is src or not dst
      then return Promise.resolve text

   Promise.resolve formats[dst][src] text, filename, vars

export formats, compile, resolve

require! './config': C
require! \fs
require(\ansicolor).nice
log = (require 'ololog').configure {+tag, -locate}
require! \jstransformer
require! \sass

render = (compiler, text, options = {}, locals = {}) ->
   Promise.resolve().then ->
      jstransformer require "jstransformer-#compiler"
      .renderAsync text, options, locals
   .then (.body)
   .catch ->
      log.error 'Missing module.'
      log "Install jstransformer-#compiler".lightGreen
      process.exit 1

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

   css:
      styl: ->
         render \stylus, &0, {filename: &1}
      sass: ->
         sass.compileString &0, {+indented} |> prop \css
      scss: ->
         sass.compileString &0 |> (.css)

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

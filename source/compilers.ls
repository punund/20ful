require! './config': C
require! fs
require(\ansicolor).nice
log = (require 'ololog').configure {+tag, -locate}

#--------------------------------------------
md = require('markdown-it')({+html})
C.'markdown-it-plugins' |> toPairs >> forEach ->
    if it.1
      try
         md.use (require resolve it.0), it.1
      catch
         log.error 'Missing module.'
         log 'Run', 'npm install'.yellow, it.0.lightGreen
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
         require! livescript
         livescript.compile &0, {filename: &1, ...&2}
   css:
      styl: ->
         require! stylus
         stylus.render &0, {filename: &1}
      scss: ->
         sass &0, {file: &1, indented: no}
      sass: ->
         sass &0, {file: &1, indented: yes}
   html:
      md: ->
         md.render &0
      pug: ->
         require! pug
         pug.render &0, {filename: &1, ...&2}
      njk: ->
         require! nunjucks
         nunjucks.renderString &0, &2

#--------------------------------------------
sass = (text, {filename, indented}) ->
   require! sass
   sass.renderSync {
      data: text
      file: filename
      indentedSyntax: indented
      }
   .css.toString!

#--------------------------------------------
compile = (dst, src, text, filename, vars) ->
   if dst is src or not dst
      then return Promise.resolve text

   Promise.resolve formats[dst][src] text, filename, vars

export formats, compile, resolve

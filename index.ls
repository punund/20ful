require! './config': C
require! './compilers': Compilers

global.Promise = require 'bluebird'
require('ansicolor').nice
fs = require('fs').promises
require! path
require! mkdirp
require! glob

log = (require 'ololog').configure \
   tag: yes, locate: no, stringify: 
      maxStringLength: 50,
      maxDepth: 6

bs = require('browser-sync').create!

require! chokidar
require! \front-matter
require! \on-change

require! 'lodash/fp': {replace, toPairs, set, sortBy,  each, \
   values, debounce, concat, get, flatten, map, split, find, _, \
   propertyOf, id}
require! lodash: {merge: merge$}  # need mutation

require! pug

sep = path.sep
pjoin = path.join
seps = new RegExp sep + '|\\.'

if C.useTemplate
   mainTemplate =  pjoin C.source, C.template

sources = C.source + '/@(html|js|css)/**/*.*'

site = {}
prom = pages: []
state = {
   +startup,
   srcCount: (.length) glob.sync sources
   }

watcher = chokidar.watch sources

#-------------------------------------------------
outputFile = (full, {outfile, body, dst, src}) -->

   if not full and dst isnt \html then return

   mkdirp path.dirname outfile
   .then ->
      if src is dst
         then body
         else Compilers[dst][src] body, outfile
   .then ->
      if dst is \html
         then pug.renderFile mainTemplate, {body: it, toc: makeToc {_: toc}}
         else it
   .then ->
      fs.writeFile outfile, it
   .then ->
      log src.green, '→', outfile.magenta, 
   .catch theError

#-------------------------------------------------
writeSite = (full) ->
   map(outputFile full) << map((.1)) << toPairs 

#-------------------------------------------------
toc = onChange {}, (path, n, p) ->
   return if state.startup
   Promise.all writeSite(no) site
   .then ->
      log.warn 'TOC changed'

#-------------------------------------------------
theError = ->
   switch it.name
      | \Error => log.error.bgMagenta it.message
      | _      => log.error.red it
   process.exit 1

#-------------------------------------------------
key_ = (x) ->
   
   x.toc?key or
   x.eleventyNavigation?key or
   ':('

#-------------------------------------------------
order_ = (x) ->

   <[ toc.order order eleventyNavigation.order ]>
   |> map (propertyOf x.attributes)
   |> find id
   |> (or -1000)

#-------------------------------------------------
watcher.on \ready !->

   log.red 'o'
   Promise.all(prom.pages)
   .each outputFile(yes)
   .then ->
      state.startup := no
      if process.env.NODE_ENV is 'production'
         then process.exit 0
         else
            bs.init {
               server: C.outroot
               files: [ C.outroot + '/**' ]
               port: 7144
               reloadOnRestart: yes
               }

   .catch theError

#-------------------------------------------------
makeToc = (x) ->

   li = switch x.dst
      | \html => "<li><a href='#{x.link}'>#{key_ x.attributes}</a>\n"
      | _     => ''
   
   ol = if x._ then "\n<ol>#{makeOl x._}</ol>\n" else ''

   li + ol
   
#-------------------------------------------------
makeOl = values >> sortBy(order_) >> map(makeToc) >> (* '')

#-------------------------------------------------
watcher.on \all, (event, infile) !->

   log event.yellow, infile # if event isnt 'change'
   # | event is \unlink
   #    fs.unlink @outfile
   #    .then log 'deleted'.red, outfile
   #    .catch -> # suppress warning
   #    return
   unless event in <[change add]> => return
   [, dst, ...link0, src] = split seps, path.normalize infile

   if dst isnt src and not Compilers[dst]?[src]
      then
         log.red "No handler for #src → #dst (#infile)"
         return

   writePromise = Promise.resolve fs.readFile infile
   .then ->  # read file
      {body, attributes} = frontMatter it.toString!
      
      [link, pathh] = 
         | attributes.index => <[ / / ]>
         | _                => ['/' + link0 * '/', link0 * '._.']

      outfile =
         | dst isnt \html => "#{C.outroot}/#{C.assets}/#dst#link.#dst"
         | _              => "#{C.outroot}#link/index.#dst"
   
      merge$ site, set link,  {dst, outfile, body, src}, {}
      merge$  toc, set pathh, {dst, attributes, link},   {}

      # log.green 'o'
      {outfile, body, dst, src}
      #
   # .tap (x)-> log src, dst, x.outfile
   .catch theError

   if state.startup
      then
         prom.pages.push writePromise
         # log.blue --state.srcCount, link0
      else writePromise.then outputFile(yes)

# EOF

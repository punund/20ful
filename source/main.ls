global <<< require 'ramda'
global <<< log: (require 'ololog').configure \
   {+tag, -locate, stringify: 
      maxStringLength: 50, maxDepth: 8}

require! './config': C
require! './compilers': Compilers
require! './toc': Toc

require(\ansicolor).nice
fs = require('fs').promises
require! path: Path # because of ramda
require! mkdirp
require! glob
require! \string-hash
require! \base58

bs = require('browser-sync').create!

require! chokidar
require! \front-matter
require! \on-change
require! pug

state = 
   rescan: no
   filecount: 0
   mode: ''

emptyLayout = src: \pug, dst: \html, body: '|!{body}'

site = {}

tocc = onChange {}, !-> state.rescan = yes

state.mode = switch process.argv[2]
| \version
   require(__dirname + '/../package.json') |> (.version) |> log
   process.exit 0
| \build => ''
| \watch => 'w'
| _      => 'bw'

state.fileCount = length glob.sync C.source + '/**/*', {+nodir}

watcher = chokidar.watch C.source, ignored: /(^|[\/\\])\../

#-------------------------------------------------
allIn = ->
   # log state.fileCount, length keys site
   state.fileCount is length keys site

#-------------------------------------------------
allDone = ->
   state.fileCount == length keys filter (prop it), site

#-------------------------------------------------
writeOne = (x, compiled) -->
   mkdirp Path.dirname x.outfile
   .then ->
      fs.writeFile x.outfile, compiled
   .then ->
      log '→', x.outfile.magenta
      x.done = 4
   .catch theError

#-------------------------------------------------
processFile = (hsh) ->

   x = site[hsh]
   
   {dir, base, ext, name} = Path.parse x.infile
   
   [, dir0, ...dirs] = split '/', dir
   dirn = (dirs * '/') or ''

   fs.readFile x.infile
   .then ->  # read file
      src = tail ext
      dst = toPairs Compilers.formats
         |> find((.1) >> has src)
         |> prop \0
         |> defaultTo src

      fm = frontMatter it.toString!
      body = fm.body
      attr = fm.attributes |> ifElse (.ignore), empty, identity
      # ---
      # ignore: true
      
      bust = if attr.'bust-cache'
         then
            state.rescan = yes
            '-' + base58.int_to_base58 stringHash body
         else ''
         
      pj = Path.join
      outfile = switch
         | attr.index    => pj C.outroot, 'index.html'
         | dir0 is \html => pj C.outroot, dirn, name, 'index.html'
         | dst           => pj C.outroot, dir0 ? '', dirn, "#name#bust.#dst"
         | _             => pj C.outroot, dir0 ? '', dirn, base
      
      link = switch
         | attr.index    => ''
         | dir0 is \html => pj dirn, name
         | dst           => pj dir0 ? '', dirn, "#name#bust.#dst"
         
      x <<< {+ping}
      tocEntry = attr.toc or attr.eleventyNavigation
      if dst is \html
         if tocEntry
            then
               tocc.{}[hsh] <<< tocEntry
               x.toc = 
                  key: tocEntry.key
                  ord: tocEntry.order
                  lnk: link
                  hsh: hsh
            else
               tocc.{}[hsh] = {}

      delete! attr.toc
      delete! attr.eleventyNavigation
            
      x <<< {outfile, body, dst, attr, link, src}

      Promise.resolve switch
      | not x.attr
         x.done = 4
      | x.attr.template
         x.done = 1.5
         log 'template'.red, x.infile.blue
      | _
         Compilers.compile dst, src, body, outfile
         .then (compiled) ->
            | x.dst is \html and x.attr.layout isnt \none
               x <<< cpld: compiled, done: 2
            | _
               writeOne x, compiled

      .then ->
         if allIn! and all ((.done) >> (> 1)), values site
            Promise.all rebuild!
            .then ->
               if state.mode is '' and all (propEq \done, 4), values site
                  process.exit 0
               

   .catch theError

#-------------------------------------------------
rebuild = ->
   toc = values site
      |> filter (.toc)
      |> map (x) ->
         x.link
            |> split '/'
            |> intersperse '_'
            |> assocPath __, $: x.toc, {}
      |> reduce mergeDeepRight, {}

   css = values site
      |> filter propEq \dst, \css
      |> filter (.attr.'bust-cache')
      |> sortBy (.attr.order)
      |> map -> "<link rel=stylesheet href='/#{it.link}'>"
      |> join ''
      
   js = []

   writes = values site
      |> filter (.done) >> (is 2)
      |> map (x) ->
         # x.done = 3
         layoutName = x.attr.layout or \system
         layout = values site
            |> find pathEq <[attr template]>, layoutName
            |> (or emptyLayout)

         Compilers.compile layout.dst, layout.src, layout.body, x.outfile, {
            ...x.attr
            body: x.cpld
            toc: Toc.build _:toc, hsh: x.toc.hsh
            css: css
            js: js
            }

         .then writeOne x
         .then ->
            layout.done = 4

#-------------------------------------------------
theError = !->
   switch it?name
      | \Error => log.error.bgMagenta it.message
      | _      => log.error.red it
   process.exit 1

#-------------------------------------------------
watcher.on \ready !->

   unless state.mode.match /b/ => return
   bs.init {
      server: C.outroot
      watch: C.outroot
      }

#-------------------------------------------------
watcher.on \all, (event, infile) !->

   hash = stringHash infile

   switch event
   | \add
      if allIn!
         ++state.fileCount
      fallthrough
   | \change
      site[hash] = {infile, done: 1}
      processFile hash
   | \unlink
      --state.fileCount
      fs.unlink site[hash]outfile
      delete tocc[hash]
      delete site[hash]
   | _
      return
   
   log event, infile.yellow

# EOF

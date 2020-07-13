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
require! base58
require! isbinaryfile

bs = require('browser-sync').create!

require! chokidar
require! \front-matter
require! \on-change
require! pug

args = require('minimist') process.argv.slice(2), default: {+serve}
if args.help
   log '''

   Commands:
      build             compile and exit
      watch             compile and watch for changes
      serve             compile, watch, start local server (default)
      proxy <port>      compile, watch, start proxy server from given port
      
   Options:
      --port <number>   server port to listen (default 3000)

   '''
   process.exit 0

args._.0 ?= \serve
args.port ?= 3000

state = 
   rescan: no
   fileCount: 0

emptyLayout = src: \pug, dst: \html, body: '|!{body}'

site = {}
# hash of input files
# "done" means: 1: read, 1.5: not html, 2: template compiled, 4: written

tocc = onChange {}, !->
   state.rescan = yes

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

   if isbinaryfile.isBinaryFileSync x.infile
      outfile = Path.join C.outroot, dir0 ? '', dirn, base
      mkdirp Path.dirname outfile
      .then ->
         fs.copyFile x.infile, outfile
      .then ->
         log '░', outfile.cyan
         x.done = 4
      return

   fs.readFile x.infile
   .then ->  # read file
      src = tail ext
      dst = toPairs Compilers.formats
         |> find((.1) >> has src)
         |> prop \0
         |> defaultTo src

      fm = frontMatter it.toString!
      body = fm.body
      # ---
      # ignore: true
      attr = fm.attributes |> ifElse (.ignore), empty, identity
      
      bust = if attr.'bust-cache'
         then
            log 'bust-cache:', x.infile.blue
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
         
      tocEntry = attr.toc or attr.eleventyNavigation
      if dst is \html
         switch
         | tocEntry
            tocc.{}[hsh] <<< tocEntry
            x.toc = 
               key: tocEntry.key
               ord: tocEntry.order
               lnk: link
               hsh: hsh
         | tocc[hsh]
            tocc[hsh] = {}

      delete! attr.toc
      delete! attr.eleventyNavigation
            
      x <<< {outfile, body, dst, attr, link, src}

      Promise.resolve switch
      | x.attr.template
         x.done = 1.5
         log 'template'.red, x.infile.blue
         state.rescan = yes
      | _
         Compilers.compile dst, src, body, outfile, attr.options
         .then (compiled) ->
            | x.dst is \html and x.attr.layout isnt \none
               x <<< cpld: compiled, done: 2
            | _
               # if dst is 'css'
               #    console.log src, compiled
               writeOne x, compiled

      .then ->
         if allIn! and (state.rescan or all ((.done) >> (> 1)), values site)
            Promise.all rebuild state.rescan
            .then ->
               if args._.0 is \build and all (propEq \done, 4), values site
                  process.exit 0
               

   .catch theError

#-------------------------------------------------
rebuild = (rescan) ->
   state.rescan = no
   valuesSite = values site

   toc = valuesSite
      |> filter (.toc)
      |> map (x) ->
         x.link
            |> split '/'
            |> intersperse '_'
            |> assocPath __, $: x.toc, {}
      |> reduce mergeDeepRight, {}

   css = valuesSite
      |> filter propEq \dst, \css
      |> filter (.attr.'bust-cache')
      |> sortBy (.attr.order)
      |> map -> "<link rel=stylesheet href='/#{it.link}'>"
      |> join ''
      
   js = []

   writes = valuesSite
      |> filter ifElse always(rescan),
         has \cpld
         propEq \done, 2
      |> map (x) ->
         layoutName = x.attr.layout or \system
         layout = valuesSite
            |> find pathEq <[attr template]>, layoutName
            |> (or emptyLayout)

         Compilers.compile layout.dst, layout.src, layout.body, x.outfile, {
            ...x.attr
            body: x.cpld
            toc: Toc.build _:toc, hsh: x.toc?hsh
            css: css
            js: js
            }

         .then (c) ->
            unless x.done > 2
               x.done = 3
               writeOne x, c
         .then ->
            layout.done = 4

#-------------------------------------------------
theError = !->
   switch it?name
      | \Error => log.error.yellow it
      | _      => log.error.red it
   process.exit 1

#-------------------------------------------------
watcher.on \ready !->

   if state.fileCount is 0
      log.warn "“#{C.source}” is empty or doesn't exit"
   else
      log.info "found #{state.fileCount} files"

   switch args._.0
   | \serve
      bs.init {
         files: C.outroot
         server: C.outroot
         watch: yes
         }
   | \proxy
      bs.init {
         port: args.port
         files: C.outroot
         watch: yes
         proxy: {target: "http://localhost:#{args._.1}", +ws}
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
      bin = isbinaryfile.isBinaryFileSync infile
      site[hash] = {infile, done: 1, bin}
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

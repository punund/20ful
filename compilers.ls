require! './config': C
require! 'lodash/fp': {toPairs,  each}

md = require('markdown-it')({+html})
C.markdown-it-plugins |> toPairs >> each ->
   md.use (require it.0), it.1 if it.1

export
   js:
      ls: (text, filename) ->
         require! livescript
         livescript.compile text, {filename, const: yes}
   css:
      styl: (text, filename) ->
         require! stylus
         stylus.render text, {filename}
   html:
      md: (text, filename) ->
         md.render text

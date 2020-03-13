#-------------------------------------------------
build = (y) ->

   hsh = y.hsh

   makeOl = values >> sortBy(path <[$ ord]>) >> map(desc) >> (* '')

   function desc x
      li = switch
         | not x.$?key
            ''
         | hsh is x.$.hsh
            "<li class=current-item>#{x.$.key}\n"
         | _
            "<li><a href='/#{x.$.lnk}'>#{x.$.key}</a>\n"

      ol = if x._
         then "\n<ol>#{makeOl x._}</ol>\n"
         else ''

      li + ol

   desc y

export build

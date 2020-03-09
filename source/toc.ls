#-------------------------------------------------
build = (x) ->

   li = if x.$?key
      then "<li><a href='/#{x.$.lnk}'>#{x.$.key}</a>\n"
      else ''

   ol = if x._
      then "\n<ol>#{makeOl x._}</ol>\n"
      else ''

   li + ol
   
#-------------------------------------------------
makeOl = values >> sortBy(path <[$ ord]>) >> map(build) >> (* '')

export build

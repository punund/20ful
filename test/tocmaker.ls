global <<< require 'ramda'
require! ava: test
require! '../bin/toc.js'

test ' makes TOC', ->>
   x =
      _: 
         aa: $: key: \ak1, lnk: \al1
         bb: $: key: \bk1, lnk: \bl1, hsh: \abc
      hsh:
         'abc'

   built = toc.build x
   it.is built, """

      <ol><li><a href='/al1'>ak1</a>
      <li class=current-item>bk1
      </ol>
      
      """

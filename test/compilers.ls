global <<< require 'ramda'
require! ava: test
require! '../bin/compilers.js'

test ' compile LiveScript', ->>
   compiled = await compilers.compile(\js, \ls, 'a |> b', \file, {+bare, -header})
   it.is compiled, "b(\na);"

test ' compile Pug', ->>
   compiled = await compilers.compile(\html, \pug, 'p text', \file)
   it.is compiled, '<p>text</p>'

test ' compile Stylus', ->>
   compiled = await compilers.compile(\css, \styl, "p\n  color red", \file)
   it.is compiled, 'p {\n  color: #f00;\n}\n'

# test ' compile SASS', ->>
#    compiled = await compilers.compile \css, \sass, """
#    $base: red;
#    p
#      color: $base"""
#    it.is compiled, 'p {\n  color: red;\n}'

test ' compile SCSS', ->>
   compiled = await compilers.compile \css, \scss, """
   $base: red;
   p {color: $base;}"""
   it.is compiled, 'p {\n  color: red;\n}'

test ' compile Markdown', ->>
   compiled = await compilers.compile(\html, \md, '# Header', \file)
   it.is compiled, "<h1>Header</h1>\n"

test ' pass through', ->>
   compiled = await compilers.compile(\xyz, \xyz, "Quick brown", \file)
   it.is compiled, 'Quick brown'

test ' recognize its suffixes', ->
   dst = toPairs compilers.formats |> find((.1) >> has 'pug') |> prop \0
   it.is dst, \html

test ' reject not its suffixes', ->
   dst = toPairs compilers.formats |> find((.1) >> has 'puxx') |> prop \0
   it.falsy dst

test ' compile Pug templates', ->>
   compiled = await compilers.compile(\html, \pug, 'p foo !{foo}', \file,
      {foo: '!{bubu}'})
   it.is compiled, '<p>foo !{bubu}</p>'

test ' compile Nunjucks', ->>
   compiled = await compilers.compile(\html, \njk,
      '<p>{{ "foo" + foo }}</p>', \file, {foo: \bar})
   it.is compiled, '<p>foobar</p>'

test ' compile Nunjucks templates', ->>
   compiled = await compilers.compile(\html, \njk,
      '<meta/>{{ x | safe }}', \file, {x: '<link>data</link>'})
   it.is compiled, '<meta/><link>data</link>'

test ' resolve local modules' ->
   aaa = compilers.resolve 'aaa'
   it.is aaa, 'aaa'

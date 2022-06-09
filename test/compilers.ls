global <<< require 'ramda'
require! ava: test
require! '../bin/compilers.js'

const CC = compilers.compile
const file = \filename


test ' compile LiveScript', ->>
   compiled = await CC \js, \ls, 'a |> b', file, {+bare, -header}
   it.is compiled, "b(\na);"

test ' compile Pug', ->>
   compiled = await CC \html, \pug, 'p(a) text', file
   it.is compiled, '<p a="a">text</p>'

test ' compile Stylus', ->>
   compiled = await CC \css, \styl, "p\n  color red", file
   it.is compiled, 'p {\n  color: #f00;\n}\n'

test ' compile SASS', ->>
   compiled = await CC \css, \sass, """
   $base: red
   p
     color: $base"""
   it.is compiled, 'p {\n  color: red;\n}'

test ' compile SCSS', ->>
   compiled = await CC \css, \scss, """
   $base: red;
   p {color: $base;}"""
   it.is compiled, 'p {\n  color: red;\n}'

test ' compile Markdown', ->>
   compiled = await CC \html, \md, '# Header'
   it.is compiled, "<h1>Header</h1>\n"

test ' pass through', ->>
   compiled = await CC \xyz, \xyz, "Quick brown"
   it.is compiled, 'Quick brown'

test ' recognize its suffixes', ->
   dst = toPairs compilers.formats |> find((.1) >> has 'pug') |> prop 0
   it.is dst, \html

test ' reject unknown suffixes', ->
   dst = toPairs compilers.formats |> find((.1) >> has 'puxx') |> prop 0
   it.falsy dst

test ' compile Pug with locals', ->>
   compiled = await CC \html, \pug,
      'p foo !{foo}', file, null, {foo: '!{bubu}'}
   it.is compiled, '<p>foo !{bubu}</p>'

test ' recognize Pug options', ->>
   compiled = await CC \html, \pug,
      '.foo(x-data)= foo', file, {doctype: \html}, {foo: \bar}
   it.is compiled, '<div class="foo" x-data>bar</div>'

test ' compile Nunjucks', ->>
   compiled = await CC \html, \njk,
      '<p>{{ "foo" + foo }}</p>', file, null, {foo: \bar}
   it.is compiled, '<p>foobar</p>'

test ' compile Nunjucks templates', ->>
   compiled = await CC \html, \njk,
      '<meta/>{{ x | safe }}', file, null, {x: '<link>data</link>'}
   it.is compiled, '<meta/><link>data</link>'

test ' resolve local modules' ->
   aaa = compilers.resolve 'aaa'
   it.is aaa, 'aaa'

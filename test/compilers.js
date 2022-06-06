// Generated by LiveScript 1.6.0
(function(){
  var test, compilers;
  import$(global, require('ramda'));
  test = require('ava');
  compilers = require('../bin/compilers.js');
  test(' compile LiveScript', async function(it){
    var compiled;
    compiled = (await compilers.compile('js', 'ls', 'a |> b', 'file', {
      bare: true,
      header: false
    }));
    return it.is(compiled, "b(\na);");
  });
  test(' compile Pug', async function(it){
    var compiled;
    compiled = (await compilers.compile('html', 'pug', 'p text', 'file'));
    return it.is(compiled, '<p>text</p>');
  });
  test(' compile Stylus', async function(it){
    var compiled;
    compiled = (await compilers.compile('css', 'styl', "p\n  color red", 'file'));
    return it.is(compiled, 'p {\n  color: #f00;\n}\n');
  });
  test(' compile SASS', async function(it){
    var compiled;
    compiled = (await compilers.compile('css', 'sass', "$base: red\np\n  color: $base"));
    return it.is(compiled, 'p {\n  color: red;\n}');
  });
  test(' compile SCSS', async function(it){
    var compiled;
    compiled = (await compilers.compile('css', 'scss', "$base: red;\np {color: $base;}"));
    return it.is(compiled, 'p {\n  color: red;\n}');
  });
  test(' compile Markdown', async function(it){
    var compiled;
    compiled = (await compilers.compile('html', 'md', '# Header', 'file'));
    return it.is(compiled, "<h1>Header</h1>\n");
  });
  test(' pass through', async function(it){
    var compiled;
    compiled = (await compilers.compile('xyz', 'xyz', "Quick brown", 'file'));
    return it.is(compiled, 'Quick brown');
  });
  test(' recognize its suffixes', function(it){
    var dst;
    dst = prop('0')(
    find(compose$(function(it){
      return it[1];
    }, has('pug')))(
    toPairs(compilers.formats)));
    return it.is(dst, 'html');
  });
  test(' reject not its suffixes', function(it){
    var dst;
    dst = prop('0')(
    find(compose$(function(it){
      return it[1];
    }, has('puxx')))(
    toPairs(compilers.formats)));
    return it.falsy(dst);
  });
  test(' compile Pug templates', async function(it){
    var compiled;
    compiled = (await compilers.compile('html', 'pug', 'p foo !{foo}', 'file', {
      foo: '!{bubu}'
    }));
    return it.is(compiled, '<p>foo !{bubu}</p>');
  });
  test(' compile Nunjucks', async function(it){
    var compiled;
    compiled = (await compilers.compile('html', 'njk', '<p>{{ "foo" + foo }}</p>', 'file', {
      foo: 'bar'
    }));
    return it.is(compiled, '<p>foobar</p>');
  });
  test(' compile Nunjucks templates', async function(it){
    var compiled;
    compiled = (await compilers.compile('html', 'njk', '<meta/>{{ x | safe }}', 'file', {
      x: '<link>data</link>'
    }));
    return it.is(compiled, '<meta/><link>data</link>');
  });
  test(' resolve local modules', function(it){
    var aaa;
    aaa = compilers.resolve('aaa');
    return it.is(aaa, 'aaa');
  });
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
  function compose$() {
    var functions = arguments;
    return function() {
      var i, result;
      result = functions[0].apply(this, arguments);
      for (i = 1; i < functions.length; ++i) {
        result = functions[i](result);
      }
      return result;
    };
  }
}).call(this);

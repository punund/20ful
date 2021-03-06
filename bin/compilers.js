// Generated by LiveScript 1.6.0
(function(){
  var C, fs, log, jstransformer, trns, render, filters, md, formats, compile, out$ = typeof exports != 'undefined' && exports || this;
  C = require('./config');
  fs = require('fs');
  require('ansicolor').nice;
  log = require('ololog').configure({
    tag: true,
    locate: false
  });
  jstransformer = require('jstransformer');
  trns = map(function(k){
    return function(){
      return jstransformer(require("jstransformer-" + k)).renderAsync(arguments[0], {
        filename: arguments[1]
      }).then(prop('body'));
    };
  })(
  {
    styl: 'stylus',
    sass: 'sass',
    scss: 'scss'
  });
  render = function(compiler, text, options, locals){
    options == null && (options = {});
    locals == null && (locals = {});
    return jstransformer(require("jstransformer-" + compiler)).renderAsync(text, options, locals).then(prop('body'));
  };
  filters = {
    markdown: function(){
      return md.render(arguments[0]);
    }
  };
  md = require('markdown-it')({
    html: true
  });
  compose$(toPairs, forEach(function(it){
    var e;
    if (it[1]) {
      try {
        return md.use(require(resolve(it[0])), it[1]);
      } catch (e$) {
        e = e$;
        log.error('Missing module.');
        log('Install', it[0].lightGreen);
        return process.exit(1);
      }
    }
  }))(
  C['markdown-it-plugins']);
  function resolve(module){
    var local;
    local = process.cwd() + '/node_modules/' + module;
    if (fs.existsSync(local)) {
      return local;
    } else {
      return module;
    }
  }
  formats = {
    js: {
      ls: function(){
        return render('livescript', arguments[0], (import$({
          filename: arguments[1]
        }, arguments[2])));
      }
    },
    css: trns,
    html: {
      md: function(){
        return md.render(arguments[0]);
      },
      pug: function(){
        return render('pug', arguments[0], {
          filters: filters,
          filename: arguments[1]
        }, arguments[2]);
      },
      njk: function(){
        return render('nunjucks', arguments[0], {
          filters: filters,
          filename: arguments[1]
        }, arguments[2]);
      }
    }
  };
  compile = function(dst, src, text, filename, vars){
    if (dst === src || !dst) {
      return Promise.resolve(text);
    }
    return Promise.resolve(formats[dst][src](text, filename, vars));
  };
  out$.formats = formats;
  out$.compile = compile;
  out$.resolve = resolve;
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
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);

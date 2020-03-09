// Generated by LiveScript 1.6.0
(function(){
  var build, makeOl, join$ = [].join, out$ = typeof exports != 'undefined' && exports || this;
  build = function(x){
    var li, ref$, ol;
    li = (ref$ = x.$) != null && ref$.key ? "<li><a href='/" + x.$.lnk + "'>" + x.$.key + "</a>\n" : '';
    ol = x._ ? "\n<ol>" + makeOl(x._) + "</ol>\n" : '';
    return li + ol;
  };
  makeOl = compose$(values, sortBy(path(['$', 'ord'])), map(build), (function(it){
    return join$.call(it, '');
  }));
  out$.build = build;
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

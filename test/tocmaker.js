// Generated by LiveScript 1.6.0
(function(){
  var test, toc;
  import$(global, require('ramda'));
  test = require('ava');
  toc = require('../bin/toc.js');
  test(' makes TOC', async function(it){
    var x, built;
    x = {
      _: {
        aa: {
          $: {
            key: 'ak1',
            lnk: 'al1'
          }
        },
        bb: {
          $: {
            key: 'bk1',
            lnk: 'bl1'
          }
        }
      }
    };
    built = toc.build(x);
    return it.is(built, "\n<ol><li><a href='/al1'>ak1</a>\n<li><a href='/bl1'>bk1</a>\n</ol>\n");
  });
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
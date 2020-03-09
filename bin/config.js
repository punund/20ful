// Generated by LiveScript 1.6.0
(function(){
  var yaml, log, fs, userConfigFile, defaultConfig, userConfg;
  yaml = require('yaml');
  log = require('ololog').configure({
    tag: true,
    locate: false
  });
  fs = require('fs');
  userConfigFile = process.cwd() + '/20ful-config.yaml';
  defaultConfig = {
    source: 'src'
    /* Where source files live.  Directory structure under "source":
       html: everything that compiles to html (markdown, html)
       Every other file will be compiled (or not) and placed in the 
      "outroot" directory, preserving directory structure.
    */,
    outroot: '_site'
    /* Directory trees under "source"/html and "source" will be preserved under
      "outroot". */,
    'markdown-it-plugins': {
      'markdown-it-mark': true,
      'markdown-it-multimd-table': {
        headerless: true,
        multiline: true,
        rowspan: true
      }
    }
  };
  module.exports = fs.existsSync(userConfigFile) ? (userConfg = yaml.parse(fs.readFileSync(userConfigFile, 'utf8')), mergeDeepLeft(userConfg, defaultConfig)) : defaultConfig;
}).call(this);

require! yaml
log = (require 'ololog').configure {+tag, -locate}
require! fs

userConfigFile = process.cwd! + '/20ful-config.yaml'

defaultConfig =
   source: \src
   /* Where source files live.  Directory structure under "source":
      html: everything that compiles to html (markdown, html)
      Every other file will be compiled (or not) and placed in the 
     "outroot" directory, preserving directory structure.
   */
   outroot: \_site
   /* Directory trees under "source"/html and "source" will be preserved under
     "outroot". */

   'markdown-it-plugins':
      # Plugin name is a key, its options is a value, "off" to disable
      'markdown-it-mark': on
      'markdown-it-multimd-table':
         headerless: true,
         multiline: true,
         rowspan: true


module.exports = if fs.existsSync userConfigFile
   then
      userConfg = yaml.parse fs.readFileSync userConfigFile, \utf8
      mergeDeepLeft userConfg, defaultConfig
   else
      defaultConfig

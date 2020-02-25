export
   formats:
      # file suffixes define what they compile to.  Only what's supported here.
      # Actual configuration is in compilers.ls
      js: <[ ls coffee ]>
      css: <[ sass styl ]>
      html: <[ pug md ]>
      
   source: \src
   /* Where source files live.  Directory structure under "source":
      html: everything that compiles to html (markdown, html)
         Every file becomes a directory with index.html inside.
         Designate one of the files site's index by including
         "index: true" in the front matter.
      css:  everything that compiles to css (stylus, sass)
      js:   everything that compiles to client side js (LiveScript, CoffeScript)
      
   */
   outroot: \_site
   /* Directory trees under "source"/html will be preserved under "outroot".
      Other compiled stuff goes to:
      css: "source"/"assets"/css
      js:  "source"/"assets"/js
   */
   assets: '.asset'
   # CSS and JS files end up in assets. Use
   # <script src=/.assets/js/...>
   # <link rel=stylesheet href=/.assets/js/...>

   useTemplate: yes
   template: '_include/main.pug'
   /* If you use a template, it lives in "source"/"template".
   It must reference a variable "body" to include a file being rendered,
   and may make use of table of content with "toc" variable.
   */

   markdown-it-plugins:
      # Plugin name is a key, its options is a value, "off" to disable
      'markdown-it-mark': on
      'markdown-it-div': on
      'markdown-it-attrs': on 
      'markdown-it-ins': on
      'markdown-it-multimd-table':
         headerless: true,
         multiline: true,
         rowspan: true

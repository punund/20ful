
# 20ful

Static site generator that makes sense.

## Installation

````
$ npm init
$ npm install 20ful
````
````
$ mkdirp src/html
$ cat > src/html/start.md
---
index: true
---
# Hello world!
^D
$ 20ful
````

## Running and command line options

Running

`20ful build`
compiles your input files and exits

`20ful watch`
compiles your input files and watches for changes

`20ful`
all the above, and starts web browser

## What it does

The generator takes in your input files, possibly applies conversions, and
writes them out.

## Conversions

The generator natively supports following transformations:
* for HTML: Markdown (`.md`), Pug (`.pug`), Nunjucks (`.njk`)
* for CSS: Stylus (`.styl`), Sass (`.scss`, `.sass`)
* for JavasScript: LiveScript (`.ls`)

Some directives may be given in the front matter (FM) of individual files. File
type is determined by its suffix.  All other files are copied as is to their
destinations, including plain HTML, CSS, and JavasScript. FM is, however, always
stripped.

## Directory structure

Place all your stuff in `src/`. It will get compiled and placed into
`_site/`, preserving directory structure.  Dot files are ignored.

Folder `src/html` is special, the "html" part will be stripped in the resulting
path, and for files compiled to HTML file name is made a folder, and the content
is placed in `index.html` in it:

    src/server-config       → \_site/server-config
    src/assets/css/main.styl → \_site/assets/css/main.css
    src/html/mypage.md       → \_site/mypage/index.html

The reason is that sometimes hosters want you to put extra stuff in the site's
root, and it's better to keep it separate from your pages:

    src/CNAME                → \_site/CNAME
    src/html/file.txt        → \_site/file.txt

This also means that if you create two files whose pathnames are different only
in `html/` part, only one of them will get to the output location, so don't do
that.

Additionally, if there is `index: true` in the front matter, the extra folder
is stripped too:

    src/html/introduction.md → \_site/index.html

provided that `introduction.md` looks like
````
---
index: true
---
# Introduction

Welcome to lorem ips...
````

## Config file

User configuration is read from `./20ful-config.yaml`.  The defaults are:

````
source:  src
outroot: _site
markdown-it-plugins:
  markdown-it-mark: true
  markdown-it-multimd-table:
    headerless:   true
    multiline:    true
    rowspan:      true
````

Markdown-it-plugins are what they appear to be. To add a markdown-it plugin:
* `npm install markdown-it-plugin-name`
* mention it in the config (`false` to disable)

If the plugin takes options, give them as sub-keys.

## Integrated functionality

This is what is called "plugins" elsewhere. This project is tiny (300 lines),
so we can't be bothered with plugins.

### Templates

Templates have `template: <name>` in their FM. Source files are processed
depending on the attribute `layout` in FM:
* `layout: <name>` named template is used
* `layout: none` no template is used
* no `layout` key: template "system" is used

Templated file is compiled into a `body` variable, which the template must
mention in unsafe mode (`!{body}`, `{{body | safe}}`).

### Table of content

Templated files may have `toc` object in their front matter (or
`eleventyNavigation`), containing `key` and `order` attributes. The `key`
becomes the item's label for the generated table of content. Links are
generated automatically.

Table of content is hierarchical and follows the directory structure. To have a
useful table of content organize your files:

````
      My-Stories.md           [FM]  toc: key: My cool stories
      My-Stories/
         Cool-story-1.md      [FM]  toc: key: First cool story
         ...
````
This way there is no need to specify a parent, and you can rearrange your
pages just moving them around, and TOC will be automatically rebuilt, and
will render to an ordered list: `<ol><li><a href='/'>First chapter</a...`

The TOC is placed in `toc` variable, which templates must unsafely include.

### Cache busting

Cache busting of CSS and JS assets may be done by automatically adding a suffix
to the filename, changing as the file content changes.  To use it, place
`bust-cache: true` in the FM, and there will be variables `css` and `js` to use
in your templates, which generates the whole `<link>` and `<script>` attributes
which you need to pass verbatim to templates:

* in Pug: `| !{css}`, `| !{js}`
* in Nunjucks: `{{ css | safe }}`, `{{ js | safe }}`

For all files that compile to CSS `css` variable stores a sequence of `link`
tags:

    <link rel=stylesheet href='/path/filename-34856.css><link ...
    
For all files that compile to JavasScript `js` variable stores a sequence of
`script` tags:

    <script src='/path/filename-51536.js><js ...

To control the order of tags, include attribute `order` in the FM: `order: 20`.

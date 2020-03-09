# 20ful

Static site generator that makes sense.

## Installation

````
$ npm init -y
$ npm install 20ful
````
````
$ mkdir -p src/html
$ cat > src/html/start.md
---
index: true
layout: none
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

Any file can have YAML-formatted front matter (FM), which is stripped after
processing.

## Conversions

The generator natively supports following conversions:
* for HTML: Markdown (`.md`), Pug (`.pug`), Nunjucks (`.njk`)
* for CSS: Stylus (`.styl`), Sass (`.scss`, `.sass`)
* for JavaScript: LiveScript (`.ls`)

File type is determined by its suffix.  All other files are copied as is to
their destinations, including plain HTML, CSS, and JavasScript.

## Directory structure

Put all your stuff in `src/`. It will get compiled and placed into
`_site/`, preserving directory structure.  Dot files are ignored.

Folder `src/html` is special, the "html" part will be stripped in the resulting
path, and for files compiled to HTML file name is made a folder, and the content
is placed in `index.html` in it:

    src/server-config        → \_site/server-config
    src/assets/css/main.styl → \_site/assets/css/main.css
    src/html/mypage.md       → \_site/mypage/index.html

The reason is that sometimes hosters want you to put extra stuff in the site's
root, and it's better to keep it separate from your pages:

    src/CNAME                → \_site/CNAME
    src/html/file.txt        → \_site/file.txt
    src/html/.git/           → (ignored)

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

## Other functionality

This is what is called "plugins" elsewhere.

### Templates

Templates have `template: <name>` in their FM. Source files are processed
depending on the attribute `layout` in the front matter:
* `layout: <name>` named template is used
* `layout: none` no template is used
* no `layout` key: template "system" is used

Templated file is compiled into a `body` variable, which the template must
mention in unsafe mode (`!{body}`, `{{body | safe}}`).

There is no designated location to store your templates, as long as they are
within `_src`, nor there are required filenames for them.

All the scalar front matter variables are passed back to the template, e.g. 
you may have set the title:

````
---
title: My page
---
````
so that the template may have `<title>#{title} | My site</title>` etc.

Please note that a `system` template is used by default, so if you don't want
any template, you may either

* put `layout: none` in every file's FM
* place somewhere a Pug file :
````
---
template: system
---
!{body}
````
and your HTML will be wrapped in new shiny nothing.

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
will render to an ordered list: `<ol><li><a href='/'>My cool stories</a...`

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

## Motivation

I was amazed by the amount of effort put by people into something as simple as
site generators, and at the same time frustrated by the absence of obvious
functionality, such as preprocessing of CSS.

This project is not nearly as grandiose (under 350 lines of code as of now),
but it covers most basic needs.

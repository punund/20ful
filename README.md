# 20ful

Static site generator that makes sense.

## Installation

````
$ npm init -y
$ npm install 20ful
````

## Quick start

````
$ mkdir -p src/html
$ cat > src/html/hello.md
---
index: true
---
# Hello world!
^D
$ 20ful
````

You can also check the [example project](https://github.com/punund/20ful-example).

## Running and command line options

`20ful build`
compiles your input files and exits

`20ful watch`
compiles your input files and watches for changes

`20ful`
all the above, and starts web browser

## What it does

The generator takes in your input files, possibly applies conversions, and
writes them out.

## Directory structure

Put all your stuff in `src/`. It will get compiled and placed into
`_site/`, preserving directory structure.  Dot files are ignored.

    src/server-config        → \_site/server-config
    src/assets/css/main.styl → \_site/assets/css/main.css
    src/html/.git/           → (ignored)

Folder `src/html/` is special, the "html" part will be stripped in the resulting
path, and for files compiled to HTML file name is made a folder, and the content
is placed in `index.html` in it:

    src/html/mypage.md       → \_site/mypage/index.html

The reason is that sometimes hosters want you to put extra stuff in the site's
root, and it's better to keep it separate from your pages.

This also means that if you create two files whose pathnames are different only
in `html/` part, only one of them will get to the output location, so don't do
that.

## Conversions

The generator natively supports following conversions:
* for HTML: Markdown (`.md`), Pug (`.pug`), Nunjucks (`.njk`)
* for CSS: Stylus (`.styl`), Sass (`.scss`, `.sass`)
* for JavaScript: LiveScript (`.ls`)

File type is determined by its suffix.  All other files are copied as is to
their destinations, including plain HTML, CSS, and JavasScript.

Any file can have YAML-formatted front matter (FM), which is stripped after
processing.  Some behavior is defined by the front matter data.

## Front matter attributes

### template: *name*

The file is a template, normally `pug` or `njk`. There is no designated location
to store your templates, as long as they are within `src`, nor there are any
particular filenames that you must give them. The following template
variables are special:

#### body
The rendered file that used this template.

#### toc
Table of content, or navigation, within an `<ol>`. Built from `toc` attributes,
see below.

#### css
Set of `<link>` attributes referring to CSS files, if cache busting is enabled.
See below.

#### js
Set of `<script>` attributes referring to JS files, if cache busting is enabled.

All special variables contain HTML and therefore must be passed in unsafe mode.
Default template `system` is always present, and just renders the body, so you
may want to name your first template "system".

### layout: _name_

The file is rendered using the named template. Possible values:

* _some name_
named template is used.
* `none`
no template is used
* _(attribute not present)_
template "system" is used

### index: _boolean_

If set to true, this file is written to top-level `index.html` in the output
direcory.

### toc:

Object, describing a table of content entry. Its attributes:

* key: (visible label in the TOC link)
* order: (entries are sorted using this value)

Table of content is hierarchical and follows the directory structure. To have a
useful table of content organize your files:

      My-Stories.md           [FM]  toc:
                                       key: My cool stories
      My-Stories/
         Cool-story-1.md      [FM]  toc:
                                       key: First cool story
                                       order: 10
         Another-story.md     [FM]  toc: ...

There is no need (and no way) to specify a parent, you can rearrange your
pages just moving them around, and TOC will be automatically rebuilt, and
will render to an ordered list: `<ol><li><a href='/'>My cool stories</a...`


### bust-cache: _boolean_

If set to "true", enables cache busting for this CSS or JS file. Cache busting
of CSS and JS assets is done by automatically adding a hash suffix to the
filename, changing as the file content changes.  Template variables `css` and
`js` will have the whole sequences of `<link>` and `<script>` attributes which
you need to pass verbatim to templates.

For all files that compile to CSS `css` variable stores a sequence of `link`
tags:

    <link rel=stylesheet href='/path/filename-34856.css'><link ...
    
For all files that compile to JavasScript `js` variable stores a sequence of
`script` tags:

    <script src='/path/filename-51536.js'><js ...

In a pug template, put `| !{css}` and `| !{js}` within the head.

### order: _number_

This controls the order of tags within cache-busted `css` and `js` variables.

### ignore: _boolean_

If set to true, this file is skipped.


## Config file

User configuration is read from `./20ful-config.yaml`.  The defaults are:

```
source:  src
outroot: _site
markdown-it-plugins:
  markdown-it-mark: true
  markdown-it-multimd-table:
    headerless:   true
    multiline:    true
    rowspan:      true
```

Markdown-it-plugins are what they appear to be. To add a markdown-it plugin:
* `npm install markdown-it-plugin-name`
* mention it in the config (`false` to disable)

If the plugin takes options, give them as sub-keys.

## Motivation

I was amazed by the amount of effort put by people into something as simple as
site generators, and at the same time frustrated by the absence of obvious
functionality, such as preprocessing of CSS.

This project is not nearly as grandiose (under 350 lines of code as of now),
still it covers most basic needs.

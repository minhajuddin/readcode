# readcode http://readcode.in/

## Core TODO
  [x] Allows you to read all the code of any repository on a single page
  [x] Syntax highlighting
  [ ] Inline the highlight css
  [ ] Good cache strategy
  [ ] Timeout if we can't load the repo or if the repo is too large
  [ ] Gzip compression for html files
  [ ] Deploy to simplepage.in server
  [ ] Ability to read code for different branches, tags, commits
  [ ] Allow ignoring of files, e.g. ?/vendor
  [ ] A badge to link to the source similar to godoc
  [ ] Sourcegraph examples
  [ ] Epub/PDF/Mobi format export
  [ ] Ability to choose a theme from pygment themes
  [ ] Add a gittip button

## Design TODO
  [ ] Make the site look nicer and responsive
  [ ] Add a nice logo


## Tech
  readcode couldn't have been built without standing on the shoulders of these
  giants:
    - [Rugged/libgit2](https://github.com/libgit2/rugged) for the git interface
    - [Pygments](http://pygments.org/) for syntax highlighting
    - [Linguist](https://github.com/github/linguist) for identifying the language
    - [Sinatra](http://www.sinatrarb.com/) for the web framework

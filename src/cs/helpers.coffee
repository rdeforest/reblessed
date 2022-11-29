###
 * helpers.js - helpers for blessed
 * Copyright (c) 2013-2015, Christopher Jeffrey and contributors (MIT License).
 * https://github.com/chjj/blessed
###

###
 * Modules
###

fs      = require 'node:fs'
unicode = require './unicode'

###
 * Helpers
###

helpers = exports


# XXX: Maybe migrate to Object.assign
helpers.merge = (a, b) ->
  for key in b
    a[key] = b[key]

  return a


# XXX: Why does this exist?
helpers.asort = (obj) ->
  obj.sort (a, b) ->
    a = a.name.toLowerCase()
    b = b.name.toLowerCase()

    if a[0] is '.' and b[0] is '.'
      a = a[1]
      b = b[1]
    else
      a = a[0]
      b = b[0]

    a > b ? 1 : (a < b ? -1 : 0)


helpers.hsort = (obj) ->
  obj.sort (a, b) -> b.index - a.index


helpers.findFile = (start, target) ->
  return (read = (dir) ->
    for prefix in forbiddenPathPrefixes
      if dir.startsWith prefix
        return null

    try
      files = fs.readdirSync dir
    catch
      return null

    for file in files
      path = (dir is '/' ? '' : dir) + '/' + file

      if file is target
        return path

      try
        stat = fs.lstatSync(path)
      catch
        stat = null

      if stat and stat.isDirectory() and not stat.isSymbolicLink()
        out = read path

        if out
          return out

    return null
  )(start)


# Escape text for tag-enabled elements.
helpers.escape = (text) ->
  text.replace /[{}]/g, (ch) ->
    if ch is '{' then '{open}' else '{close}'


helpers.parseTags = (text, screen) ->
  helpers.Element::_parseTags
    .call {
        parseTags: true
        screen: screen || helpers.Screen.global
      }, text


helpers.generateTags = (style, text) ->
  open = close = ''

  if not style
    return { open, close }

  for key, val of style
    if 'string' is typeof val
      val = val.replace  /^light(?!-)/, 'light-'
      val = val.replace /^bright(?!-)/, 'bright-'

      open  =         '{'  + val + '-' + key + '}' + open
      close = close + '{/' + val + '-' + key + '}'
    else if val
      open  =         '{'  + key + '}' + open
      close = close + '{/' + key + '}'

  if text
    return open + text + close

  return { open, close }


helpers.attrToBinary = (style, element = {}) ->
  helpers.Element::sattr.call element, style


helpers.stripTags = (text) ->
  if not text then return ''

  return text
    .replace(/{(\/?)([\w\-,;!#]*)}/g, '')
    .replace(/\x1b\[[\d;]*m/g, '')


helpers.cleanTags = (text) ->
  helpers
    .stripTags text
    .trim()


helpers.dropUnicode = (text) ->
  if not text then return ''

  text
    .replace unicode.chars.all,       '??'
    .replace unicode.chars.combining, ''
    .replace unicode.chars.surrogate, '?'


# XXX: Ripe for re-factor
helpers.__defineGetter__ 'Screen', ->
  if not helpers._screen
    helpers._screen = require './widgets/screen'

  helpers._screen

helpers.__defineGetter__ 'Element', ->
  if not helpers._element
    helpers._element = require './widgets/element'

  helpers._element


###

# XXX: Should be using (require "node:path").join
addWidgetGetters = (names...) ->
  for name in names
    modName = name.toLowerCase()
    modPath = "./widgets/" + name

    get     = -> helpers["_" + modName] or= require modPath

    Object.defineProperty helpers, name,
      {get, configurable: true, enumerable: true} 

addWidgetGetters 'Screen', 'Element'

###

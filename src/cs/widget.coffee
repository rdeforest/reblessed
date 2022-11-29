###
 * widget.js - high-level interface for blessed
 * Copyright (c) 2013-2015, Christopher Jeffrey and contributors (MIT License).
 * https://github.com/chjj/blessed
###

widget = exports

widget.classes = [
  'Node'
  'Screen'
  'Element'
  'Box'
  'Text'
  'Line'
  'ScrollableBox'
  'ScrollableText'
  'BigText'
  'List'
  'Form'
  'Input'
  'Textarea'
  'Textbox'
  'Button'
  'ProgressBar'
  'FileManager'
  'Checkbox'
  'RadioSet'
  'RadioButton'
  'Prompt'
  'Question'
  'Message'
  'Loading'
  'Listbar'
  'Log'
  'Table'
  'ListTable'
  'Terminal'
  'Image'
  'ANSIImage'
  'OverlayImage'
  'Video'
  'Layout'
]

for name from widget.classes
  file = name.toLowerCase()
  widget[name] =
  widget[file] =
    require './widgets/' + file

widget.aliases =
  'ListBar': 'Listbar'
  'PNG': 'ANSIImage'

Object
  .keys widget.aliases
  .forEach (key) ->
    name = widget.aliases[key]
    widget[key] = widget[name]
    widget[key.toLowerCase()] = widget[name]
    return


#
# Cyclops Copy Widget
#
$.widget 'cylops.toggle',

  containerTemplate: (context) ->
    """
      <div class="cyclops-copy-widget">
        xxx
      </div>
    """

  _create: ->
    unless @element.tagName in [ 'BUTTON', 'INPUT' ]
      throw 'Copyable may only be used with <input> or <button> elements!'

    if @element.tagName is 'BUTTON' and @element.value.length is 0
      throw 'Copyable buttons must have a value attribute!'

    @isButton = (@element.tagName is 'BUTTON')

    @insertCopyButton() unless @isButton
    @addEventListeners()

    this.container = ($ this.containerTemplate
      affirmativeText: this.options.affirmativeText
      negativeText: this.options.negativeText
    )

    this.container.insertBefore this.element
    this.element.prependTo this.container.find('label')
    this.element.prop 'checked', this.options.defaults.checked
    this.element.prop 'disabled', this.options.defaults.disabled
    if this.options.defaults.disabled
      this.container.addClass 'disabled'
    this.element.on 'change.cyclops', (event) =>
      element = event.target
      this._trigger 'change', null, { checked: element.checked }

  _destroy: ->
    this._super()
    this.element.off '.cyclops'
    this.element.insertBefore this.container
    this.container.remove()
    return this

  _setChecked: (checked) ->
    this.element.prop('checked', checked)
    this._trigger 'change', null, { checked: checked }

  checked: (checked) ->
    unless checked is undefined
      this._setChecked(checked)
      return this
    else
      this.element.prop('checked')












class Copyable

  constructor: (@element) ->
    unless @element.tagName in [ 'BUTTON', 'INPUT' ]
      throw 'Copyable may only be used with <input> or <button> elements!'

    if @element.tagName is 'BUTTON' and @element.value.length is 0
      throw 'Copyable buttons must have a value attribute!'

    @isButton = (@element.tagName is 'BUTTON')

    @insertCopyButton() unless @isButton
    @addEventListeners()

  insertCopyButton: ->
    return if @isButton

    @copyButtonElement = $('<button title="Copy to Clipboard"><svg class="cyclops-icon" aria-hidden="true"><use xlink:href="#icon-clipboard" /></svg></button>')
    @copyButtonElement.insertAfter(@element)

    # Resize the input to make space for the button without changing the
    # overall width of the combined input+button.
    inputWidth = ($ @element).innerWidth()
    buttonWidth = @copyButtonElement.innerWidth()
    newInputWidth = inputWidth - buttonWidth
    ($ @element).css('width', newInputWidth)

  addEventListeners: ->
    if @isButton
      ($ @element).on 'click', @onClick
    else
      @copyButtonElement.on 'click', @onClick

  onClick: (event) =>
    copyableValue = @element.value

    # console.log '[Copyable] Value:', copyableValue

    event.preventDefault()
    event.stopPropagation()

    @copyToClipboard(copyableValue)

  copyToClipboard: (value) ->
    # console.log '[Copyable] Copying Value to Clipboard...', value

    temporaryElement = document.createElement('div')
    temporaryElement.innerText = value
    temporaryElement.style.position = 'absolute'
    temporaryElement.style.left = '-10000px'
    temporaryElement.style.top = '-10000px'
    document.body.appendChild(temporaryElement)

    selection = getSelection()
    range = document.createRange()
    selection.removeAllRanges()
    range.selectNodeContents(temporaryElement)
    selection.addRange(range)
    document.execCommand('copy', false, null)
    selection.removeAllRanges()

    temporaryElement.parentElement.removeChild(temporaryElement)

$.fn.copyable = (options) ->
  options = $.extend { }, options
  $(this).each (idx, input) ->
    copyableInstance = new Copyable(input)
  $(this)

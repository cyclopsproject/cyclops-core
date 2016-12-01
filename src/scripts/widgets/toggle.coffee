#
# Cyclops Toggle Widget
#
# Usage:
#
#   TODO
#
$.widget 'cylops.toggle',

  container: null

  options:
    affirmativeText: 'yes'
    defaults:
      checked: false
      disabled: false
    negativeText: 'no'

  containerTemplate: (context) ->
    """
      <div class="cyclops-toggle-widget">
        <label>
          <div class="text">
            <div class="affirmative">#{context.affirmativeText}</div>
            <div class="negative">#{context.negativeText}</div>
          </div>
          <svg class="handle" aria-hidden="true">
            <use xlink:href="#icon-handle" />
          </svg>
        </label>
      </div>
    """

  _create: ->
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
    if this.options.onChange
      this.element.on 'change', (event) =>
        element = event.target
        this.options.onChange(element.checked)

  _destroy: ->
    this._super()
    this.element.off 'change'
    this.element.insertBefore this.container
    this.container.remove()
    return this

  _setChecked: (checked) ->
    this.element.prop('checked', checked)
    # this._trigger 'valueChange', null, {value: value}

  checked: (checked) ->
    unless checked is undefined
      this._setChecked(checked)
      return this
    else
      this.element.prop('checked')

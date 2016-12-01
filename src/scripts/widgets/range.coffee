# TODO: disable txtINput when range disabled

$.widget 'cyclops.range',

  containerTemplate: (context) ->
    """
      <div class="range-container">
          <input class="form-control" type="number" min="#{context.min}" max="#{context.max}" step="#{context.step}"/>
          <div class="range-input-container"></div>
      </div>
    """

  _create: ->
    this.boundValues = {
      min: parseInt(this.element.attr('min'), 10) ? 1
      max: parseInt(this.element.attr('max'), 10) ? 128
      step: parseInt(this.element.attr('step'), 10) ? 1
    }

    $container = ($ this.containerTemplate this.boundValues)
    this.$txtInput = $container.find ".form-control"

    # ensure there is a min, max, and step on the input we are bound to
    this.element.attr {
      'min': this.boundValues.min
      'max': this.boundValues.max
      'step': this.boundValues.step
    }

    $container.insertBefore this.element
    $container.find(".range-input-container").append this.element

    # contrain and set the value of the textbox and range
    value = this._constrainValue parseInt(this.element.val(), 10)
    this.$txtInput.val value
    this.element.val value

    # wire up listeners to input event and update other input and fire change event
    this.element.on 'input.cyclops', (event) =>
      this.$txtInput.val event.target.value
      this._trigger 'valueChange', null, {value: event.target.value}
    this.$txtInput.on 'input.cyclops', (event) =>
      this.element.val event.target.value
      this._trigger 'valueChange', null, {value: event.target.value}

  _constrainValue: (value) ->
    # keep the value inside the min and max
    if value < this.boundValues.min
      value = this.boundValues.min
    else if value > this.boundValues.max
      value = this.boundValues.max
    return value

  _setValue: (value) ->
    value = this._constrainValue value
    this.element.val value
    this.$txtInput.val value
    this._trigger 'valueChange', null, {value: value}

  _refreshValue: () ->
    oldVal = parseInt this.element.val(), 10
    # try to contrain the value
    newVal = this._constrainValue oldVal
    # if the value changes set a new value
    if oldVal != newVal
      this._setValue newVal

  _setOption: (key, value) ->
    this._super key, value

  _destroy: ->
    # remove all namespaced handlers
    this.element.off '.cyclops'
    container = this.element.parents('.range-container')
    this.element.insertBefore container
    container.remove()

  value: (value) ->
    # if a value is passed treat this call as a setter
    if not (value == undefined)
      this._setValue value
      return
    # if no value is passed treat this call as a getter
    else
      return parseInt this.element.val(), 10

  max: (value) ->
    # if a value is passed treat this call as a setter
    if not (value == undefined)
      if value < this.boundValues.min
        throw "#{value} is not greater than #{this.boundValues.min}: The max value must be greater than the min value"
      this.boundValues.max = value
      this._refreshValue()
      this.element.attr 'max', value
      this.$txtInput.attr 'max', value
      return
    # if no value is passed treat this call as a getter
    else
      return this.boundValues.max

  min: (value) ->
    # if a value is passed treat this call as a setter
    if not (value == undefined)
      if value > this.boundValues.max
        throw "#{value} is greater than #{this.boundValues.max}: The min value must not be greater than the max value"
      this.boundValues.min = value
      this._refreshValue()
      this.element.attr 'min', value
      this.$txtInput.attr 'min', value
      return
    # if no value is passed treat this call as a getter
    else
      return this.boundValues.min

  step: (value) ->
    # if a value is passed treat this call as a setter
    if not (value == undefined)
      this.boundValues.step = value
      this.element.attr 'step', value
      this.$txtInput.attr 'step', value
      return
    # if no value is passed treat this call as a getter
    else
      return this.boundValues.step

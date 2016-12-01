describe 'Widgets: Toggle', ->

  beforeEach ->
    this.element = ($ """<input type="checkbox">""").appendTo('body')
    this.onChangeHandler = jasmine.createSpy('onChange')

  describe 'Initialization', ->

    it 'initializes', ->
      toggleWidget = this.element.toggle()
      # TODO Does $.widget() set any data we can inspect?
      expect(toggleWidget).not.toBeNull()

    it 'initializes in an unchecked state by default', ->
      expect(this.element.toggle().prop('checked')).toBe(false)

    it 'initializes in a checked state', ->
      this.element.toggle(defaults: { checked: true })
      expect(this.element.prop('checked')).toBe(true)

    it 'initializes in a disabled state', ->
      this.element.toggle(defaults: { disabled: true })
      expect(this.element.prop('disabled')).toBe(true)

    it 'initializes in an explicitly unchecked state', ->
      this.element.toggle(defaults: { checked: false })
      expect(this.element.prop('checked')).toBe(false)

    it 'wraps the element', ->
      toggleWidget = this.element.toggle()
      expect(this.element.parents('.cyclops-toggle-widget').length).toBeGreaterThan(0)

    it 'observes the element for change events', ->
      toggleWidget = this.element.toggle(onChange: this.onChangeHandler)
      eventHandlers = $._data(this.element[0], 'events')
      expect(eventHandlers.change.length).toBe(1);

  describe 'Cleanup', ->

    xit 'destroys', ->
      toggleWidget = this.element.toggle()
      # TODO: There's probably a better check to see that the widget is destroyed
      expect(toggleWidget.toggle('destroy'))

    it 'stops observing for events on the element', ->
      toggleWidget = this.element.toggle(onChange: this.onChangeHandler)
      eventHandlers = $._data(this.element[0], 'events')
      toggleWidget.toggle('destroy')
      expect($._data(this.element, "events")).toBe(undefined)

    it 'removes container from the DOM', ->
      toggleWidget = this.element.toggle()
      toggleWidget.toggle('destroy')
      expect(this.element.parents('.cyclops-toggle-widget').length).toBe(0)

  describe 'Public Methods', ->

    describe 'checked', ->

      it 'sets the checked state', ->
        toggleWidget = this.element.toggle(defaults: { checked: false })
        expect(toggleWidget.toggle('checked')).toBe(false)
        toggleWidget.toggle('checked', true)
        expect(toggleWidget.toggle('checked')).toBe(true)

      it 'returns the checked state', ->
        toggleWidget = this.element.toggle(defaults: { checked: true })
        expect(toggleWidget.toggle('checked')).toBe(true)

      it 'returns the instance when setting the checked state', ->
        toggleWidget = this.element.toggle()
        expect(toggleWidget.toggle('checked', true)).toEqual(toggleWidget)

  describe 'Events', ->

    it 'calls the onChange callback for change events', ->
      this.element.toggle(onChange: this.onChangeHandler)
      this.element.prop('checked', true)
      this.element.trigger('change')
      expect(this.onChangeHandler).toHaveBeenCalledWith(true)

    it 'calls the onChange callback for click events', ->
      this.element.toggle(onChange: this.onChangeHandler)
      this.element.trigger('click')
      expect(this.onChangeHandler).toHaveBeenCalledWith(true)

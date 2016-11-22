describe 'toggle widget', ->

  beforeEach ->
    # console.log("Hi")

  afterEach ->
    # console.log("Bye")

  it 'contains spec with an expectation', ->
    expect(true).toBe(true)

  it 'initializes an instance of the toggle widget', ->
    element = ($ """<input type="checkbox">""").appendTo('body')
    console.log('element', element)
    toggleWidget = element.toggle()
    console.log('toggleWidget', toggleWidget)
    element.trigger('click');
    # console.log('body', document.body)

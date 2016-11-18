describe 'toggle widget', ->
  it 'contains spec with an expectation', ->
    expect(true).toBe(true)

  it 'initializes an instance of the toggle widget', ->
    toggleWidget = ($ "<div></div>").toggle()
    console.log('toggleWidget', toggleWidget)

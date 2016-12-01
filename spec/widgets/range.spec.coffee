describe 'Widgets: range', ->
  beforeEach jasmine.prepareTestNode
  it 'hangs off the global jquery fn object', ->
    expect(jQuery.fn.range).toBeDefined()

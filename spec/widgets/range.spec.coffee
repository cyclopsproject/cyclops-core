describe 'Widgets: range', ->
  beforeEach jasmine.prepareTestNode

  it 'hangs off the global jquery fn object', ->
    expect(jQuery.fn.range).toBeDefined()

  it 'wraps the input', ->
    input = $('<input id="customRange" type="range" value="40" min="0" max="100" step="10" />')
    $(testNode).append input
    $('#customRange').range()
    expect(input.parents('.range-container').length).toBeGreaterThan(0);

  it 'sets the min max step value disabled of the input', ->
    input = $('<input id="customRange" disabled type="range" value="40" min="0" max="100" step="10" />')
    $(testNode).append input
    $('#customRange').range()
    txtInput = $('input[type=number]')
    expect(txtInput.attr('min')).toBe("0")
    expect(txtInput.attr('max')).toBe("100")
    expect(txtInput.attr('step')).toBe("10")
    expect(txtInput.val()).toBe("40")
    expect(txtInput.prop('disabled')).toBe(true)

  it 'sets the value of the range when a number is typed', ->
    input = $('<input id="customRange" type="range" value="40" min="0" max="100" step="10" />')
    $(testNode).append input
    $('#customRange').range()
    txtInput = $('input[type=number]')
    txtInput.val(50)
    # you have to manual trigger this as setting the value programitically doesn't
    txtInput.trigger 'input'
    expect($('#customRange').val()).toBe("50")

  it 'sets the value of the input when the range changes', ->
    input = $('<input id="customRange" type="range" value="40" min="0" max="100" step="10" />')
    $(testNode).append input
    $('#customRange').range()
    txtInput = $('input[type=number]')
    $('#customRange').val(50)
    # you have to manual trigger this as setting the value programitically doesn't
    $('#customRange').trigger 'input'
    expect(txtInput.val()).toBe("50")

  it 'allows value to be read programitically', ->
    input = $('<input id="customRange" type="range" value="40" min="0" max="100" step="10" />')
    $(testNode).append input
    widget = $('#customRange').range()
    expect(widget.range('value')).toBe(40)

  it 'allows value to be set programitically', ->
    input = $('<input id="customRange" type="range" value="40" min="0" max="100" step="10" />')
    $(testNode).append input
    widget = $('#customRange').range()
    txtInput = $('input[type=number]')
    widget.range('value', 50)
    expect(txtInput.val()).toBe("50")
    expect(widget.val()).toBe("50")

  it 'constrains the value to max when set programitically', ->
    input = $('<input id="customRange" type="range" value="40" min="0" max="100" step="10" />')
    $(testNode).append input
    widget = $('#customRange').range()
    widget.range('value', 150)
    expect(widget.range('value')).toBe(100)

  it 'constrains the value to min when set programitically', ->
    input = $('<input id="customRange" type="range" value="40" min="0" max="100" step="10" />')
    $(testNode).append input
    widget = $('#customRange').range()
    widget.range('value', -10)
    expect(widget.range('value')).toBe(0)

  it 'allows the max value to be read programitically', ->
    input = $('<input id="customRange" type="range" value="40" min="0" max="100" step="10" />')
    $(testNode).append input
    widget = $('#customRange').range()
    expect(widget.range('max')).toBe(100)

  it 'allows the max value to be set programitically', ->
    input = $('<input id="customRange" type="range" value="40" min="0" max="100" step="10" />')
    $(testNode).append input
    widget = $('#customRange').range()
    widget.range('max', 150)
    expect(widget.range('max')).toBe(150)

  it 'does not allows the max value to be smaller than min when set programitically', ->
    input = $('<input id="customRange" type="range" value="40" min="0" max="100" step="10" />')
    $(testNode).append input
    widget = $('#customRange').range()
    expect( () ->
      widget.range('max', -10)
    ).toThrow()

  it 'constrains the value when the max to a smaller value', ->
    input = $('<input id="customRange" type="range" value="40" min="0" max="100" step="10" />')
    $(testNode).append input
    widget = $('#customRange').range()
    widget.range('max', 30)
    expect(widget.range('value')).toBe(30)

  it 'allows the min value to be read programitically', ->
    input = $('<input id="customRange" type="range" value="40" min="0" max="100" step="10" />')
    $(testNode).append input
    widget = $('#customRange').range()
    expect(widget.range('min')).toBe(0)

  it 'allows the min value to be set programitically', ->
    input = $('<input id="customRange" type="range" value="40" min="0" max="100" step="10" />')
    $(testNode).append input
    widget = $('#customRange').range()
    widget.range('min', 10)
    expect(widget.range('min')).toBe(10)

  it 'does not allows the min value to be greater than max when set programitically', ->
    input = $('<input id="customRange" type="range" value="40" min="0" max="100" step="10" />')
    $(testNode).append input
    widget = $('#customRange').range()
    expect( () ->
      widget.range('min', 110)
    ).toThrow()

  it 'constrains the value when the min to a greater value', ->
    input = $('<input id="customRange" type="range" value="40" min="0" max="100" step="10" />')
    $(testNode).append input
    widget = $('#customRange').range()
    widget.range('min', 50)
    expect(widget.range('value')).toBe(50)

  it 'allows the step value to be read programitically', ->
    input = $('<input id="customRange" type="range" value="40" min="0" max="100" step="10" />')
    $(testNode).append input
    widget = $('#customRange').range()
    expect(widget.range('step')).toBe(10)

  it 'allows the step value to be set programitically', ->
    input = $('<input id="customRange" type="range" value="40" min="0" max="100" step="10" />')
    $(testNode).append input
    widget = $('#customRange').range()
    widget.range('step', 20)
    expect(widget.range('step')).toBe(20)

  it 'allows the disabled property to be read programitically', ->
    input = $('<input id="customRange" type="range" value="40" min="0" max="100" step="10" />')
    $(testNode).append input
    widget = $('#customRange').range()
    expect(widget.range('disable')).toBe(false)

  it 'allows the disabled value to be set programitically', ->
    input = $('<input id="customRange" type="range" value="40" min="0" max="100" step="10" />')
    $(testNode).append input
    widget = $('#customRange').range()
    widget.range('disable', true)
    expect(widget.range('disable')).toBe(true)
    widget.range('disable', false)
    expect(widget.range('disable')).toBe(false)

import { Toggleable } from '../../src/scripts/widgets/toggleable';

describe('Widgets: Toggle', function() {

  var testElement, onChangeHandler;

  beforeEach(function() {
    testElement = document.createElement('input');
    testElement.type = 'checkbox';
    document.body.appendChild(testElement);

    onChangeHandler = jasmine.createSpy('onChange');
  });

  describe('Initialization', () => {

    it('initializes', () => {
      let toggleableInstance = new Toggleable(testElement);
      expect(toggleableInstance).not.toBeNull();
    });

    it('initializes in an unchecked state by default', () => {
      let toggleableInstance = new Toggleable(testElement);
      expect(testElement.checked).toBe(false);
    });

    it('initializes in a checked state', () => {
      let toggleableInstance = new Toggleable(testElement, { defaults: { checked: true } });
      expect(testElement.checked).toBe(true);
    });

    it('initializes in a disabled state', () => {
      let toggleableInstance = new Toggleable(testElement, { defaults: { disabled: true } });
      expect(testElement.disabled).toBe(true);
    });

    it('initializes in an explicitly unchecked state', () => {
      let toggleableInstance = new Toggleable(testElement, { defaults: { checked: false } });
      expect(testElement.disabled).toBe(false);
    });

    it('wraps the element', () => {
      let toggleableInstance = new Toggleable(testElement);
      expect(testElement.closest('.cyclops-toggleable-wrapper').length).toBeGreaterThan(0)
    });

    xit('observes the element for change events', () => {
      // TODO: It's not possible to lookup event handlers added with addEventListener
      let toggleableInstance = new Toggleable(testElement, { onChange: onChangeHandler });
      // eventHandlers = $._data(this.element[0], 'events')
      // expect(eventHandlers.change.length).toBe(1);
    });

  });

  describe('Cleanup', () => {

    it('destroys', () => {
      let toggleableInstance = new Toggleable(testElement);
      expect(toggleableInstance.destroy());
    });

    xit('stops observing for events on the element', function() {
      // var eventHandlers, toggleWidget;
      // toggleWidget = this.element.toggle({
      //   onChange: this.onChangeHandler
      // });
      // eventHandlers = $._data(this.element[0], 'events');
      // toggleWidget.toggle('destroy');
      // return expect($._data(this.element, "events")).toBe(void 0);
    });

    it('removes container from the DOM', function() {
      let toggleableInstance = new Toggleable(testElement);
      toggleableInstance.destroy();
      return expect(this.element.parents('.cyclops-toggle-widget').length).toBe(0);
    });
  });

describe('Public Methods', function() {
  return describe('checked', function() {
    it('sets the checked state', function() {
      var toggleWidget;
      toggleWidget = this.element.toggle({
        defaults: {
          checked: false
        }
      });
      expect(toggleWidget.toggle('checked')).toBe(false);
      toggleWidget.toggle('checked', true);
      return expect(toggleWidget.toggle('checked')).toBe(true);
    });
    it('returns the checked state', function() {
      var toggleWidget;
      toggleWidget = this.element.toggle({
        defaults: {
          checked: true
        }
      });
      return expect(toggleWidget.toggle('checked')).toBe(true);
    });
    return it('returns the instance when setting the checked state', function() {
      var toggleWidget;
      toggleWidget = this.element.toggle();
      return expect(toggleWidget.toggle('checked', true)).toEqual(toggleWidget);
    });
  });
});

describe('Events', function() {
  it('triggers the change event for input change events', function() {
    this.element.toggle({
      change: this.onChangeHandler
    });
    this.element.prop('checked', true);
    this.element.trigger('change');
    expect(this.onChangeHandler).toHaveBeenCalled();
    return expect(this.onChangeHandler.calls.mostRecent().args[1]).toEqual({
      checked: true
    });
  });
  return it('calls the change event for click events', function() {
    this.element.toggle({
      change: this.onChangeHandler
    });
    this.element.trigger('click');
    expect(this.onChangeHandler).toHaveBeenCalled();
    return expect(this.onChangeHandler.calls.mostRecent().args[1]).toEqual({
      checked: true
    });
  });
});

});

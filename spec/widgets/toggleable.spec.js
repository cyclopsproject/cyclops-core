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

    xit('initializes in a checked state', () => {
      let toggleableInstance = new Toggleable(testElement, { defaults: { checked: true } });
      expect(testElement.checked).toBe(true);
    });

    xit('initializes in a disabled state', () => {
      let toggleableInstance = new Toggleable(testElement, { defaults: { disabled: true } });
      expect(testElement.disabled).toBe(true);
    });

    it('wraps the element', () => {
      let toggleableInstance = new Toggleable(testElement);
      expect(testElement.parentNode.tagName).toEqual('LABEL');
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

    it('removes container from the DOM', function() {
      let toggleableInstance = new Toggleable(testElement);
      toggleableInstance.destroy();
      expect(testElement.parentNode.tagName).toEqual('BODY');
    });
  });

  // Public Method Tests -------------------------------------------------------

  describe('Public Methods', () => {

    describe('checked', () => {

      xit('sets the checked state', () => {
        var toggleWidget;
        toggleWidget = this.element.toggle({
          defaults: {
            checked: false
          }
        });
        expect(toggleWidget.toggle('checked')).toBe(false);
        toggleWidget.toggle('checked', true);
        expect(toggleWidget.toggle('checked')).toBe(true);
      });

      xit('returns the checked state', () => {
        var toggleWidget;
        toggleWidget = this.element.toggle({
          defaults: {
            checked: true
          }
        });
        expect(toggleWidget.toggle('checked')).toBe(true);
      });

      xit('returns the instance when setting the checked state', () => {
        var toggleWidget;
        toggleWidget = this.element.toggle();
        expect(toggleWidget.toggle('checked', true)).toEqual(toggleWidget);
      });
    });
  });

  // Event Tests ---------------------------------------------------------------

  describe('Events', () => {
    xit('triggers the change event for input change events', () => {
      this.element.toggle({
        change: this.onChangeHandler
      });
      this.element.prop('checked', true);
      this.element.trigger('change');
      expect(this.onChangeHandler).toHaveBeenCalled();
      expect(this.onChangeHandler.calls.mostRecent().args[1]).toEqual({
        checked: true
      });
    });

    xit('calls the change event for click events', () => {
      this.element.toggle({
        change: this.onChangeHandler
      });
      this.element.trigger('click');
      expect(this.onChangeHandler).toHaveBeenCalled();
      expect(this.onChangeHandler.calls.mostRecent().args[1]).toEqual({
        checked: true
      });
    });
  });

});

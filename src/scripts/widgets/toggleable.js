class Toggleable {

  constructor(element, options = {}) {
    console.log('element', element);
    if (element.tagName !== 'INPUT' && element.type !== 'checkbox') {
      throw ('Toggleable may only be used with <input type="checkbox"> elements!');
    }

    this.element = element;
    this.containerElement = this.containerTemplate();
    this.element.insertAdjacentElement('beforebegin', this.containerElement);
    this.containerElement.querySelector('label').insertAdjacentElement('afterbegin', this.element);

    this.addEventListeners();
  }

  addEventListeners() {
    let onChangeHandler = this.onChange.bind(this);
    this.element.addEventListener('change', onChangeHandler);
  }

  onChange(event) {
    let checkedValue = this.element.checked;

    event.preventDefault();
    event.stopPropagation();

    console.log('[Toggleable] Checked?', checkedValue);
  }

  containerTemplate(context = {}) {
    let element = document.createElement('div');
    element.innerHTML = `
      <div class="cyclops-toggleable-wrapper">
        <label>
          <div class="text">
            <div class="affirmative">${context.affirmativeText || "On"}</div>
            <div class="negative">${context.negativeText || "Off"}</div>
          </div>
          <svg class="handle" aria-hidden="true">
            <use xlink:href="#icon-handle" />
          </svg>
        </label>
      </div>
    `.trim();
    return element.firstChild;
  }

  toggle(checked) {
    if (checked === undefined) {
      return this.element.checked = !this.element.checked;
    } else if (checked === true) {
      return this.element.checked = true;
    } else {
      return this.element.checked = false;
    }
  }

}

//   options:
//     affirmativeText: 'yes'
//     defaults:
//       checked: false
//       disabled: false
//     negativeText: 'no'

//   _create: ->
//     this.container = ($ this.containerTemplate
//       affirmativeText: this.options.affirmativeText
//       negativeText: this.options.negativeText
//     )

//     this.container.insertBefore this.element
//     this.element.prependTo this.container.find('label')
//     this.element.prop 'checked', this.options.defaults.checked
//     this.element.prop 'disabled', this.options.defaults.disabled
//     if this.options.defaults.disabled
//       this.container.addClass 'disabled'
//     this.element.on 'change.cyclops', (event) =>
//       element = event.target
//       this._trigger 'change', null, { checked: element.checked }

//   _destroy: ->
//     this._super()
//     this.element.off '.cyclops'
//     this.element.insertBefore this.container
//     this.container.remove()
//     return this

//   _setChecked: (checked) ->
//     this.element.prop('checked', checked)
//     this._trigger 'change', null, { checked: checked }

//   checked: (checked) ->
//     unless checked is undefined
//       this._setChecked(checked)
//       return this
//     else
//       this.element.prop('checked')

// let toggleables = new Array();
// let initialize = function() {
//   let toggleableElements = [].slice.call(document.body.querySelectorAll('[data-behavior="toggleable"]')); // the [].slice.call(...) is for NodeList.forEach compatibility...
//   // let toggleables = new Array();
//
//   console.log('[Toggleable] Elements', toggleableElements);
//
//   toggleableElements.forEach((toggleableElement) => {
//     let toggleable = new Toggleable(toggleableElement);
//     toggleables.push(toggleable);
//   });
//
//   console.info('[Toggleable] Instances:', toggleables);
// };
//
// document.addEventListener('DOMContentLoaded', initialize);

export default Toggleable;

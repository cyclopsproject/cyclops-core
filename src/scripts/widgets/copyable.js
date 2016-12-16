class Copyable {

  constructor(element) {
    if (!['BUTTON', 'INPUT'].includes(element.tagName)) {
      throw ('Copyable may only be used with <input> or <button> elements!');
    }

    if (element.tagName === 'BUTTON' && element.value.length === 0) {
      throw ('Copyable buttons must have a value attribute!');
    }

    this.element = element;
    this.isButton = (element.tagName === 'BUTTON');

    if (!this.isButton) {
      this.insertCopyButton();
    }
    this.addEventListeners();
  }

  insertCopyButton() {
    if (this.isButton) {
      return;
    }

    let copyButtonElement = document.createElement('button');
    copyButtonElement.innerHTML = 'Copy'; /* '&#x2398'; */
    copyButtonElement.title = 'Copy to Clipboard';
    this.element.insertAdjacentElement('afterend', copyButtonElement);

    // Resize the input to make space for the button without changing the
    // overall width of the combined input+button.
    let inputStyles = getComputedStyle(this.element);
    let buttonStyles = getComputedStyle(copyButtonElement);
    let inputWidth = parseFloat(inputStyles.getPropertyValue('width'));
    let buttonWidth = parseFloat(buttonStyles.getPropertyValue('width'));
    let newInputWidth = inputWidth - buttonWidth;
    this.element.style.width = `${newInputWidth}px`;

    this.copyButtonElement = copyButtonElement;
  }

  addEventListeners() {
    let onClickHandler = this.onClick.bind(this);

    if (this.isButton) {
      this.element.addEventListener('click', onClickHandler);
    } else {
      this.copyButtonElement.addEventListener('click', onClickHandler);
    }
  }

  onClick(event) {
    let copyableValue = this.element.value;

    event.preventDefault();
    event.stopPropagation();

    console.log('[Copyable] Value:', copyableValue);

    this.copyToClipboard(copyableValue)
  }

  copyToClipboard(value) {
    console.log('[Copyable] Copying Value to Clipboard...', value);

    let temporaryElement = document.createElement('div');
    temporaryElement.innerText = value;
    temporaryElement.style.position = 'absolute';
    temporaryElement.style.left = '-10000px';
    temporaryElement.style.top = '-10000px';
    document.body.appendChild(temporaryElement);

    let selection = getSelection();
    let range = document.createRange();
    selection.removeAllRanges();
    range.selectNodeContents(temporaryElement);
    selection.addRange(range);
    document.execCommand('copy', false, null);
    selection.removeAllRanges();

    temporaryElement.remove();
  }

}

// let initialize = function() {
//   let copyableElements = [].slice.call(document.body.querySelectorAll('[data-behavior="copyable"]')); // the [].slice.call(...) is for NodeList.forEach compatibility...
//   let copyables = new Array();
//
//   console.log('[Copyable] Elements', copyableElements);
//
//   copyableElements.forEach((copyableElement) => {
//     let copyable = new Copyable(copyableElement);
//     copyables.push(copyable);
//   });
//
//   console.info('[Copyable] Instances:', copyables);
// };
//
// document.addEventListener('DOMContentLoaded', initialize);

export default Copyable;

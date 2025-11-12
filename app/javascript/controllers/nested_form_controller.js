import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container", "template"];
  static values = { index: { String, default: "NEW_RECORD" } }

  addNestedForm(event) {
    event.preventDefault();

    const new_index = new Date().getTime();
    const index_pattern = new RegExp(this.indexValue, "g");
    const content = this.templateTarget.innerHTML.replace(index_pattern, new_index);

    console.log("Adding nested form at index:", new_index);
    console.log("using pattern:", index_pattern);
    console.log("using template:", this.templateTarget);

    this.containerTarget.insertAdjacentHTML("beforebegin", content);
  }

  removeNestedForm(event) {
    event.preventDefault();

    const item = event.target.closest("[data-nested-form-item]");
    console.log("Removing item:", item);

    // If the item is persisted, mark it for deletion
    const destroyInput = item.querySelector("input[name*='_destroy']");
    if (destroyInput) {
      console.log("Marking item for destruction");
      destroyInput.value = "1";
      item.style.display = "none";
    } else {
      // If it's a new item, just remove it from the DOM
      console.log("Removing new item from DOM");
      item.remove();
    }
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["nav", "container"]

  toggle() {
    this.navTarget.classList.toggle("hidden")
    this.containerTarget.classList.toggle("lg:w-72")
    this.containerTarget.classList.toggle("lg:w-20")
  }
}

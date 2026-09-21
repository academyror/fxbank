import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["container"]

  connect() {
    this.boundHandleKeyDown = this.handleKeyDown.bind(this)
    window.addEventListener("keydown", this.boundHandleKeyDown)
  }

  disconnect() {
    window.removeEventListener("keydown", this.boundHandleKeyDown)
  }

  close(event) {
    if (event) event.preventDefault()
    const frame = this.element.closest("turbo-frame")
    if (frame) {
      frame.innerHTML = ""
    } else {
      this.element.remove()
    }
  }

  closeOnBackdrop(event) {
    if (event.target === event.currentTarget) {
      this.close(event)
    }
  }

  handleKeyDown(event) {
    if (event.key === "Escape") {
      this.close(event)
    }
  }
}

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="currency-input"
export default class extends Controller {
  static targets = ["input", "preview"]

  updatePreview() {
    const rawVal = parseFloat(this.inputTarget.value) || 0
    if (this.hasPreviewTarget) {
      this.previewTarget.textContent = `$${rawVal.toFixed(2)} USD`
    }
  }
}

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="clipboard"
export default class extends Controller {
  static targets = ["source", "button"]

  copy(event) {
    event.preventDefault()
    const textToCopy = this.sourceTarget.value || this.sourceTarget.textContent.trim()

    navigator.clipboard.writeText(textToCopy).then(() => {
      this.showCopiedState()
    })
  }

  showCopiedState() {
    if (!this.hasButtonTarget) return
    const originalText = this.buttonTarget.textContent
    this.buttonTarget.textContent = "Copied! ✓"
    this.buttonTarget.classList.add("text-emerald-400")

    setTimeout(() => {
      this.buttonTarget.textContent = originalText
      this.buttonTarget.classList.remove("text-emerald-400")
    }, 2000)
  }
}

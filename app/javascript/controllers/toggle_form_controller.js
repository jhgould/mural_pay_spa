import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["formContainer", "showButton"]
  
  showForm() {
    this.formContainerTarget.classList.remove("d-none")
    this.showButtonTarget.classList.add("d-none")
  }
  
  hideForm() {
    this.formContainerTarget.classList.add("d-none")
    this.showButtonTarget.classList.remove("d-none")
  }
}

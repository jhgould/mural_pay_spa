import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  connect() {
    this.hideForm()
  }

  toggleForm(event) {
    event.preventDefault()
    
    if (this.formTarget.classList.contains('d-none')) {
      this.showForm()
    } else {
      this.hideForm()
    }
  }

  showForm() {
    this.formTarget.classList.remove('d-none')
  }

  hideForm() {
    this.formTarget.classList.add('d-none')
  }
}

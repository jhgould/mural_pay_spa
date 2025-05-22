import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name", "description", "feedback"]
  
  connect() {
    console.log("Account form controller connected")
  }
  
  handleSubmit(event) {
    if (event.detail.success) {
      this.resetForm()
      
      const toggleForm = this.element.closest("[data-controller='toggle-form']")
      if (toggleForm) {
        const toggleController = this.application.getControllerForElementAndIdentifier(toggleForm, "toggle-form")
        toggleController.hideForm()
      }
    } else {
      if (!this.feedbackTarget.innerHTML.trim()) {
        this.feedbackTarget.innerHTML = `
          <div class="alert alert-danger">
            There was an error creating the account. Please try again.
          </div>
        `
      }
    }
  }
  
  cancel(event) {
    event.preventDefault()
    this.resetForm()
    
    const toggleForm = this.element.closest("[data-controller='toggle-form']")
    if (toggleForm) {
      const toggleController = this.application.getControllerForElementAndIdentifier(toggleForm, "toggle-form")
      toggleController.hideForm()
    }
  }
  
  resetForm() {
    this.nameTarget.value = ""
    this.descriptionTarget.value = ""
    this.feedbackTarget.innerHTML = ""
  }
}

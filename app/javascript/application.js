import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener("turbo:load", () => {
  const err = document.querySelector(".text-error")
  if (err) err.scrollIntoView({ behavior: "smooth", block: "center" })
})
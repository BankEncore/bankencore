import { Application } from "@hotwired/stimulus"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
export const application = Application.start()
eagerLoadControllersFrom("controllers", application)

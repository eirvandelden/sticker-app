// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

import FadeOutController from "./fade_out_controller"
import EmojiPickerController from "./emoji_picker_controller"

window.Stimulus = Application.start()
Stimulus.register("fade-out", FadeOutController)
Stimulus.register("emoji-picker", EmojiPickerController)

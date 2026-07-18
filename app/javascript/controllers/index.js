// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

import PushController from "appkit/controllers/push_controller"
application.register("push", PushController)

import ThemeController from "appkit/controllers/theme_controller"
application.register("theme", ThemeController)

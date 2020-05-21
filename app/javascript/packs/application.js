require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

require("jquery")
require("jquery-ui")
require("bootstrap")
require("backbone")
global.$ = require("jquery")

import Backbone from "backbone"
global.Backbone = Backbone

global._ = require("underscore")

require("./pages/all")

import "css/main"

import MenusApp from "./menus/app"
window.MenusApp = MenusApp


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag "rails.png" %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context("../images", true)
// const imagePath = (name) => images(name, true)

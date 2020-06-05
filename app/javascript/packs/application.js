require("@rails/ujs").start()
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


import "css/main"

import MenuApp from "./menu/app"
window.MenuApp = MenuApp;

// const images = require.context("../images", true)
// const imagePath = (name) => images(name, true)

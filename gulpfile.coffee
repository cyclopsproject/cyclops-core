#
# Cyclops Build Script
#
# Provides the tasks for building, testing and distributing the Cyclops project
# through the use of Gulp.
#

autoprefixer = require "gulp-autoprefixer"
clean = require "gulp-clean"
cleanCSS = require "gulp-clean-css"
coffee = require "gulp-coffee"
combine = require "stream-combiner2"
concat = require "gulp-concat"
gulp = require "gulp"
less = require "gulp-less"
liveServer = require "gulp-live-server"
notifier = require "node-notifier"
rename = require "gulp-rename"
sourcemaps = require "gulp-sourcemaps"
svgmin = require "gulp-svgmin"
svgstore = require "gulp-svgstore"
uglify = require "gulp-uglify"

# Configuration ----------------------------------------------------------------

SOURCE_PATH = "src"
BUILD_OUTPUT = "build"
DISTRIBUTION_OUTPUT = "dist"
AUTOPREFIXER_OPTIONS =
  browsers: [ "ie >= 9", "last 2 versions" ]
  cascade: false
DEVELOPMENT_PORT = process.env.PORT or 4000

# Primary Tasks ----------------------------------------------------------------

gulp.task "clean", [
  "clean-images", "clean-scripts", "clean-stylesheets", # "clean-tests",
  "clean-vendor", "clean-distribution"
]

gulp.task "build", [
  "images", "scripts", "stylesheets", "vendor"
]

gulp.task "optimize", [
  "optimize-images", "optimize-scripts", "optimize-stylesheets",
  "optimize-vendor-scripts"
]

gulp.task "dev", [
  "build", "watch", "serve"
]

gulp.task "dist", [
  # "clean", "build", "test", "distribute"
  "clean", "optimize", "distribute"
]

# Image Tasks ------------------------------------------------------------------

gulp.task "images", [ "compile-images" ]

gulp.task "clean-images", ->
  gulp.src("#{BUILD_OUTPUT}/assets/images").pipe clean()

gulp.task "compile-images", ->
  # gulp.src "#{SOURCE_PATH}/assets/images/icons/**/*.svg"
  #   .pipe gulp.dest "#{BUILD_OUTPUT}/assets/images"

  # SVG Icons
  gulp.src "#{SOURCE_PATH}/assets/images/icons/**/*.svg"
    .pipe rename { prefix: "icon-" }
    .pipe svgstore { inlineSvg: true }
    .pipe rename "cyclops.icons.svg"
    .pipe gulp.dest "#{BUILD_OUTPUT}/assets/images"

gulp.task "optimize-images", [ "compile-images" ], ->
  # TODO: pngcrush, etc?

  # SVG Icons
  gulp.src "#{SOURCE_PATH}/assets/images/icons/**/*.svg"
    .pipe rename { prefix: "icon-" }
    .pipe svgmin()
    .pipe svgstore { inlineSvg: true }
    .pipe rename "cyclops.icons.min.svg"
    .pipe gulp.dest "#{BUILD_OUTPUT}/assets/images"

# Script Tasks -----------------------------------------------------------------

gulp.task "scripts", [ "compile-scripts" ]

gulp.task "clean-scripts", ->
  gulp.src("#{BUILD_OUTPUT}/scripts").pipe clean()

gulp.task "compile-scripts", ->
  concatenated = combine.obj [
    gulp.src "#{SOURCE_PATH}/scripts/**/*.coffee"
    coffee()
    sourcemaps.init()
    concat "cyclops.js"
    sourcemaps.write(".")
    gulp.dest "#{BUILD_OUTPUT}/scripts"
  ]
  concatenated.on "error", (error) ->
    console.error.bind(console)
    notifier.notify
      title: "Script Compilation Error"
      message: error.message
      contentImage: "#{SOURCE_PATH}/assets/images/cyclops.png"
      sound: true

gulp.task "optimize-scripts", [ "compile-scripts" ], ->
  gulp.src "#{BUILD_OUTPUT}/scripts/cyclops.js"
    .pipe sourcemaps.init()
    .pipe uglify()
    .pipe rename { suffix: ".min" }
    .pipe sourcemaps.write(".")
    .pipe gulp.dest "#{BUILD_OUTPUT}/scripts"

# Stylesheet Tasks -------------------------------------------------------------

gulp.task "stylesheets", [ "compile-stylesheets" ]

gulp.task "clean-stylesheets", ->
  gulp.src("#{BUILD_OUTPUT}/styles").pipe clean()

gulp.task "compile-stylesheets", ->
  combined = combine.obj [
    gulp.src "#{SOURCE_PATH}/styles/cyclops.less"
      sourcemaps.init()
      less()
      autoprefixer AUTOPREFIXER_OPTIONS
      sourcemaps.write(".")
      gulp.dest "#{BUILD_OUTPUT}/styles"
  ]
  combined.on "error", (error) ->
    console.error.bind(console)
    notifier.notify
      title: "Stylesheet Compilation Error"
      message: error.message
      contentImage: "#{SOURCE_PATH}/assets/images/cyclops.png"
      sound: true

gulp.task "optimize-stylesheets", [ "compile-stylesheets" ], ->
  gulp.src "#{BUILD_OUTPUT}/styles/cyclops.css"
    .pipe sourcemaps.init()
    .pipe cleanCSS()
    .pipe rename { suffix: ".min" }
    .pipe sourcemaps.write(".")
    .pipe gulp.dest "#{BUILD_OUTPUT}/styles"

# Vendor Tasks -----------------------------------------------------------------

gulp.task "vendor", [ "copy-vendor-scripts" ]

gulp.task "clean-vendor", ->
  gulp.src("#{BUILD_OUTPUT}/scripts/vendor").pipe clean()
  gulp.src("#{BUILD_OUTPUT}/styles/vendor").pipe clean()

gulp.task "copy-vendor-scripts", ->

  # Copy Widget Factory from jQuery UI
  gulp.src "node_modules/jquery-ui/ui/widget.js"
    .pipe sourcemaps.init()
    .pipe rename "jquery.widget.js"
    .pipe sourcemaps.write(".")
    .pipe gulp.dest "#{BUILD_OUTPUT}/scripts/vendor"

gulp.task "optimize-vendor-scripts", [ "copy-vendor-scripts" ], ->
  gulp.src "#{BUILD_OUTPUT}/scripts/vendor/**/*.js"
    .pipe sourcemaps.init()
    .pipe uglify()
    .pipe rename { suffix: ".min" }
    .pipe sourcemaps.write(".")
    .pipe gulp.dest "#{BUILD_OUTPUT}/scripts/vendor"

# Development Tasks ------------------------------------------------------------

gulp.task "watch", ->
  gulp.watch "src/styles/**/*", [ "compile-stylesheets" ]
  gulp.watch "src/scripts/**/*", [ "compile-scripts" ]
  gulp.watch "src/assets/images/**/*", [ "compile-images" ]

gulp.task "serve", ->
  server = liveServer.static(BUILD_OUTPUT, DEVELOPMENT_PORT)
  server.start()

  watchedFiles = [
    "#{BUILD_OUTPUT}/**/*.js",
    "#{BUILD_OUTPUT}/**/*.css",
    "#{BUILD_OUTPUT}/**/*.png",
    "#{BUILD_OUTPUT}/**/*.svg"
  ]

  gulp.watch watchedFiles, (file) ->
    server.notify.apply server, [ file ]

# Distribution Tasks -----------------------------------------------------------

gulp.task "distribute", [ "clean-distribution", "create-distribution" ]

gulp.task "clean-distribution", ->
  gulp.src(DISTRIBUTION_OUTPUT).pipe clean()

gulp.task "create-distribution", [ "clean-distribution", "build" ], ->

  # Copy Build Output
  gulp.src BUILD_OUTPUT
    .pipe gulp.dest DISTRIBUTION_OUTPUT

# Default Gulp Task ------------------------------------------------------------

gulp.task "default", [ "build" ]

#
# # Cyclops Build Script
#
# Provides the tasks for building, testing and distributing the Cyclops project
# through the use of Gulp.
#
# ## Tasks
#
#   * `gulp compile` will compile all of the assets, scripts, styles and website
#      into the `build` folder. The website may be viewed by opening the
#      `build/website/index.html` file.
#
#   * `gulp optimize` will optimize all of the built output (i.e. minimizing
#     styles and scripts, compressing images, etc). The optimized output will
#     be written to the `build` folder.
#
#   * `gulp dist` will compile, optimize and package Cyclops for distribution
#     in the `dist` folder. The current version in `package.json` will be used
#     as the name of its containing folder in `dist`.
#
#   * `gulp watch`
#
# The default task is `watch`.
#

# Dependencies -----------------------------------------------------------------

autoprefixer = require 'gulp-autoprefixer'
cleanCSS = require 'gulp-clean-css'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
del = require 'del'
gulp = require 'gulp'
less = require 'gulp-less'
liveServer = require 'gulp-live-server'
notifier = require 'node-notifier'
pkg = require './package.json'
plumber = require 'gulp-plumber'
rename = require 'gulp-rename'
sourcemaps = require 'gulp-sourcemaps'
svgmin = require 'gulp-svgmin'
svgstore = require 'gulp-svgstore'
symlink = require 'gulp-symlink' # TODO: We don't need this in Gulp 4
uglify = require 'gulp-uglify'

# Configuration ----------------------------------------------------------------

isWatching = false

paths =
  scripts:
    core: 'src/scripts'
    vendor: 'vendor/scripts'
    website: 'src/website/styles'
  styles:
    core: 'src/styles'
    vendor: 'vendor/styles'
    website: 'src/website/styles'
  assets:
    base: 'src/assets'
    fonts: 'src/assets/fonts'
    icons: 'src/assets/images/icons'
    images: 'src/assets/images'
  build:
    base: 'build'
    assets: 'build/assets'
    styles: 'build/styles'
    scripts: 'build/scripts'
    images: 'build/assets/images'
    icons: 'build/assets/images/icons'
    website: 'build/website'
  distribution:
    base: 'dist'

options =
  autoprefixer:
    browsers: [ 'ie >= 9', 'last 2 versions' ]
    cascade: false
  less:
    paths: [
      "#{__dirname}/#{paths.styles.core}",
      "#{__dirname}/#{paths.styles.website}"
    ]
  liveServer:
    port: process.env.PORT or 4000
  plumber:
    errorHandler: (error) ->
      if isWatching
        console.error error.stack
        notifier.notify
          title: 'Cyclops Core Error'
          message: error.message
          contentImage: "#{__dirname}/#{paths.assets.images}/cyclops.png"
          sound: true
      else
        throw error

# Primary Tasks ----------------------------------------------------------------

gulp.task 'clean', [
  'clean-assets', 'clean-scripts', 'clean-styles', 'clean-vendor',
  'clean-distribution', 'clean-website'
] # , (cb) -> cb()

gulp.task 'compile', [
  'compile-assets', 'compile-scripts', 'compile-styles',
  'compile-vendor-scripts', 'compile-website'
]

gulp.task 'optimize', [
  'optimize-assets', 'optimize-scripts', 'optimize-styles',
  'optimize-vendor-scripts', 'optimize-website'
]

gulp.task 'dev', [
  'compile', 'watch', 'serve'
]

gulp.task 'dist', [
  'clean', 'distribute'
]

# Asset Tasks ------------------------------------------------------------------

gulp.task 'assets', [ 'clean-assets', 'compile-assets', 'optimize-assets' ]

gulp.task 'clean-assets', ->
  del.sync paths.build.assets

gulp.task 'compile-assets', ->

  # SVG Icons
  gulp.src "#{paths.assets.icons}/**/*.svg"
    .pipe rename(prefix: 'icon-')
    .pipe svgstore(inlineSvg: true)
    .pipe rename('cyclops.icons.svg')
    .pipe gulp.dest(paths.build.icons)

gulp.task 'optimize-assets', [ 'compile-assets' ], ->

  # TODO: pngcrush, etc?

  # SVG Icons
  gulp.src "#{paths.assets.icons}/**/*.svg"
    .pipe rename(prefix: 'icon-')
    .pipe svgmin()
    .pipe svgstore(inlineSvg: true)
    .pipe rename('cyclops.icons.min.svg')
    .pipe gulp.dest(paths.build.icons)

# Script Tasks -----------------------------------------------------------------

gulp.task 'scripts', [ 'clean-scripts', 'compile-scripts', 'optimize-scripts' ]

gulp.task 'clean-scripts', ->
  del.sync paths.build.scripts

gulp.task 'compile-scripts', ->

  # CoffeeScript Files
  gulp.src "#{paths.scripts.core}/**/*.coffee"
    .pipe plumber(options.plumber)
    .pipe coffee()
    .pipe sourcemaps.init()
    .pipe concat('cyclops.js')
    .pipe sourcemaps.write('.')
    .pipe gulp.dest(paths.build.scripts)

  # TODO: ES6 via Babel

gulp.task 'optimize-scripts', [ 'compile-scripts' ], ->
  gulp.src "#{paths.build.scripts}/cyclops.js"
    .pipe plumber(options.plumber)
    .pipe sourcemaps.init()
    .pipe uglify()
    .pipe rename(suffix: '.min')
    .pipe sourcemaps.write('.')
    .pipe gulp.dest(paths.build.scripts)

# Stylesheet Tasks -------------------------------------------------------------

gulp.task 'styles', [ 'clean-styles', 'compile-styles', 'optimize-styles' ]

gulp.task 'clean-styles', ->
  del.sync paths.build.styles

gulp.task 'compile-styles', ->
  gulp.src [ "#{paths.styles.core}/cyclops.less", "#{paths.styles.website}/site.less" ]
    .pipe plumber(options.plumber)
    .pipe sourcemaps.init()
    .pipe less(options.less)
    .pipe autoprefixer(options.autoprefixer)
    .pipe sourcemaps.write('.')
    .pipe gulp.dest(paths.build.styles)

gulp.task 'optimize-styles', [ 'compile-styles' ], ->
  gulp.src [ "#{paths.build.styles}/**/*.css", "!#{paths.build.styles}/**/*.css" ]
    .pipe sourcemaps.init()
    .pipe cleanCSS()
    .pipe rename(suffix: '.min')
    .pipe sourcemaps.write('.')
    .pipe gulp.dest(paths.build.styles)

# Vendor Tasks -----------------------------------------------------------------

gulp.task 'vendor', [
  'clean-vendor', 'compile-vendor-scripts', 'optimize-vendor-scripts',
  'compile-vendor-styles', 'optimize-vendor-styles'
]

gulp.task 'clean-vendor', ->
  del.sync [ paths.scripts.vendor, paths.styles.vendor ]

gulp.task 'compile-vendor-scripts', ->

  # Copy Vendor Scripts
  gulp.src "#{paths.scripts.vendor}/**/*.js"
    .pipe sourcemaps.init()
    .pipe sourcemaps.write('.')
    .pipe gulp.dest("#{paths.build.scripts}/vendor")

  # Compile and Copy Vendor CoffeeScripts
  gulp.src "#{paths.scripts.vendor}/**/*.coffee"
    .pipe plumber(options.plumber)
    .pipe coffee()
    .pipe sourcemaps.init()
    .pipe sourcemaps.write('.')
    .pipe gulp.dest("#{paths.build.scripts}/vendor")

  # Copy Widget Factory from jQuery UI
  gulp.src 'node_modules/jquery-ui/ui/widget.js'
    .pipe sourcemaps.init()
    .pipe rename('jquery.widget.js')
    .pipe sourcemaps.write('.')
    .pipe gulp.dest("#{paths.build.scripts}/vendor")

gulp.task 'optimize-vendor-scripts', [ 'compile-vendor-scripts' ], ->
  gulp.src [ "#{paths.build.scripts}/vendor/**/*.js", "!#{paths.build.scripts}/vendor/**/*.min.js" ]
    .pipe sourcemaps.init()
    .pipe uglify()
    .pipe rename(suffix: '.min')
    .pipe sourcemaps.write('.')
    .pipe gulp.dest("#{paths.build.scripts}/vendor")

gulp.task 'compile-vendor-styles', ->
  # TODO: Implement

gulp.task 'optimize-vendor-styles', [ 'compile-vendor-styles' ], ->
  # TODO: Implement

# Development Tasks ------------------------------------------------------------

gulp.task 'watch', [ 'compile' ], ->

  isWatching = true

  # Styles
  gulp.watch "{#{paths.styles.core},#{paths.styles.vendor},#{paths.styles.website}}/**/*", [ 'compile-styles' ]
  gulp.watch "{#{paths.scripts.core},#{paths.scripts.vendor}}/**/*", [ 'compile-scripts' ]
  gulp.watch "{#{paths.assets.base}}/**/*", [ 'compile-assets' ]

gulp.task 'serve', [ 'watch' ], ->
  server = liveServer.static(paths.build.website, options.liveServer.port)
  server.start()

  gulp.watch "#{paths.build.base}/**/*.{css,js,png,svg}", (file) ->
    server.notify.apply server, [ file ]

# Website Tasks ----------------------------------------------------------------

gulp.task 'website', [ 'clean-website', 'compile-website', 'optimize-website' ]

gulp.task 'clean-website', ->
  del.sync paths.build.website

gulp.task 'compile-website', ->
  # TODO: Replace with a more modern hbs compiler setup
  hbs = require 'express-hbs'
  through = require 'through2'

  gulp.src 'src/website/**/*.html'
    .pipe through.obj (file, enc, cb) ->
      render = hbs.create().express3
        viewsDir: "src/website"
        partialsDir: 'src/website/partials'
        layoutDir: 'src/website/layouts'
        defaultLayout: 'src/website/layouts/default.html'
        extName: 'html'
      locals = {
        settings: {
          views: 'src/website'
        },
        version: pkg.version
      }
      render file.path, locals, (err, html) =>
        if (!err)
          file.contents = new Buffer(html)
          this.push(file)
          cb()
        else
          console.log 'failed to render #{file.path}'
          console.log err
    .pipe gulp.dest(paths.build.website)

  # Symlink Styles and Scripts
  gulp.src paths.build.styles
    .pipe symlink("#{paths.build.website}/css", force: true)
  gulp.src paths.build.scripts
    .pipe symlink("#{paths.build.website}/scripts", force: true)

gulp.task 'optimize-website', [ 'compile-website' ], ->
  # TODO: We probably don't need this.

# Distribution Tasks -----------------------------------------------------------

gulp.task 'distribute', [ 'clean-distribution', 'create-distribution' ]

gulp.task 'clean-distribution', ->
  del.sync "#{paths.distribution}/#{pkg.version}"

gulp.task 'clean-all-distributions', ->
  del.sync paths.distribution

# TODO: Make this do the optimization
# TODO: Format the dist folder as dist/version/...
gulp.task 'create-distribution', [ 'clean-distribution', 'build' ], ->

  # Copy Build Output
  gulp.src paths.build.base
    .pipe gulp.dest("#{paths.distribution.base}/#{pkg.version}")

# Default Gulp Task ------------------------------------------------------------

gulp.task 'default', [ 'serve' ]

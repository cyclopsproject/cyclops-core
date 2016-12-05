#
# # Cyclops Build Script
#
# Provides the tasks for building, testing and distributing the Cyclops project
# through the use of Gulp.
#
# ## Tasks
#
#   * `gulp clean`
#
#   * `gulp compile` will compile all of the assets, scripts, styles and website
#      into the `build` folder. The website may be viewed by opening the
#      `build/website/index.html` file.
#
#   * `gulp optimize` will optimize all of the built output (i.e. minimizing
#     styles and scripts, compressing images, etc). The optimized output will
#     be written to the `build` folder.
#
#   * `gulp test` and `gulp test-browsers`
#
#   * `gulp dist` will compile, optimize and package Cyclops for distribution
#     in the `dist` folder. The current version in `package.json` will be used
#     as the name of its containing folder in `dist`.
#
#   * `gulp serve`
#
# The default task is `serve`.
#

# Dependencies -----------------------------------------------------------------

del = require 'del'
gulp = require 'gulp'
notifier = require 'node-notifier'
pkg = require './package.json'
plugins = require('gulp-load-plugins')(pattern: [ 'gulp-*', 'gulp.*', '*-stream' ])
streamqueue = require 'streamqueue'
through = require 'through2'

# Configuration ----------------------------------------------------------------

isWatching = false

paths =
  scripts:
    build: 'src/build'
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
  website:
    base: 'src/website'
    partials: 'src/website/partials'
    layouts: 'src/website/layouts'
  tests:
    base: 'spec'
    helpers: 'spec/helpers'
  build:
    base: 'build'
    assets: 'build/assets'
    styles: 'build/styles'
    scripts: 'build/scripts'
    images: 'build/assets/images'
    icons: 'build/assets/images/icons'
    website: 'build/website'
    tests: 'build/tests'
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
    port: process.env.PORT or 4300
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

# Helpers ----------------------------------------------------------------------

appendStream = () ->
  pass = through.obj()
  plugins.eventStream.duplex(pass, streamqueue(objectMode: true, pass, arguments[0]))

# Assets -----------------------------------------------------------------------

cleanAssets = ->
  del paths.build.assets

compileAssets = (done) ->
  # TODO: ...
  done()

optimizeAssets = (done) ->
  # TODO: pngcrush,etc?
  done()

# Scripts ----------------------------------------------------------------------

cleanScripts = ->
  del paths.build.scripts

compileScripts = ->
  # inline icons SVGs
  # TODO: Move to assets tasks
  svgs = gulp.src "#{paths.assets.icons}/**/*.svg"
    .pipe plugins.rename(prefix: 'icon-')
    .pipe plugins.svgmin()
    .pipe plugins.svgstore(inlineSvg: true)

  afterFile = gulp.src "#{paths.scripts.build}/after.js"
    .pipe plugins.inject(svgs, {
      name: 'icons',
      transform: (filePath, file) ->
        return file.contents.toString().replace(/"/g, '\\"')
     })

  # CoffeeScript Files
  coffeeScriptFiles = gulp.src "#{paths.scripts.core}/**/*.coffee"
    .pipe plugins.plumber(options.plumber)
    .pipe plugins.coffee(bare: true)
    .pipe plugins.addSrc.prepend "#{paths.scripts.build}/before.js"
    .pipe appendStream afterFile
    .pipe plugins.sourcemaps.init()
    .pipe plugins.concat('cyclops.js')
    .pipe plugins.sourcemaps.write('.')
    .pipe gulp.dest(paths.build.scripts)

  # TODO: ES6 via Babel
  plugins.mergeStream svgs, afterFile, coffeeScriptFiles

optimizeScripts = ->
  gulp.src "#{paths.build.scripts}/cyclops.js"
    .pipe plugins.plumber(options.plumber)
    .pipe plugins.sourcemaps.init()
    .pipe plugins.uglify()
    .pipe plugins.rename(suffix: '.min')
    .pipe plugins.sourcemaps.write('.')
    .pipe gulp.dest(paths.build.scripts)

# Stylesheets ------------------------------------------------------------------

cleanStyles = ->
  del paths.build.styles

compileStyles = ->
  gulp.src [ "#{paths.styles.core}/cyclops.less", "#{paths.styles.website}/site.less" ]
    .pipe plugins.plumber(options.plumber)
    .pipe plugins.sourcemaps.init()
    .pipe plugins.less(options.less)
    .pipe plugins.autoprefixer(options.autoprefixer)
    .pipe plugins.sourcemaps.write('.')
    .pipe gulp.dest(paths.build.styles)

optimizeStyles = ->
  gulp.src [ "#{paths.build.styles}/**/*.css", "!#{paths.build.styles}/**/*.css" ]
    .pipe plugins.sourcemaps.init()
    .pipe plugins.cleanCss()
    .pipe plugins.rename(suffix: '.min')
    .pipe plugins.sourcemaps.write('.')
    .pipe gulp.dest(paths.build.styles)

# Vendor Dependencies ----------------------------------------------------------

cleanVendor = ->
  del [ paths.scripts.vendor, paths.styles.vendor ]

compileVendorScripts = ->
  plugins.mergeStream(

    # Copy Vendor Scripts
    gulp.src "#{paths.scripts.vendor}/**/*.js"
      .pipe plugins.sourcemaps.init()
      .pipe plugins.sourcemaps.write('.')
      .pipe gulp.dest("#{paths.build.scripts}/vendor")

    # Compile and Copy Vendor CoffeeScripts
    gulp.src "#{paths.scripts.vendor}/**/*.coffee"
      .pipe plugins.plumber(options.plumber)
      .pipe plugins.coffee()
      .pipe plugins.sourcemaps.init()
      .pipe plugins.sourcemaps.write('.')
      .pipe gulp.dest("#{paths.build.scripts}/vendor")

    # Copy jQuery
    gulp.src 'node_modules/jquery/dist/jquery.js'
      .pipe plugins.sourcemaps.init()
      .pipe plugins.sourcemaps.write('.')
      .pipe gulp.dest("#{paths.build.scripts}/vendor")

    # Copy Widget Factory from jQuery UI
    gulp.src 'node_modules/jquery-ui/ui/widget.js'
      .pipe plugins.sourcemaps.init()
      .pipe plugins.rename('jquery.widget.js')
      .pipe plugins.sourcemaps.write('.')
      .pipe gulp.dest("#{paths.build.scripts}/vendor")

  )

optimizeVendorScripts = ->
  gulp.src [ "#{paths.build.scripts}/vendor/**/*.js", "!#{paths.build.scripts}/vendor/**/*.min.js" ]
    .pipe plugins.sourcemaps.init()
    .pipe plugins.uglify()
    .pipe plugins.rename(suffix: '.min')
    .pipe plugins.sourcemaps.write('.')
    .pipe gulp.dest("#{paths.build.scripts}/vendor")

compileVendorStyles = ->
  # TODO: Implement

optimizeVendorStyles = ->
  # TODO: Implement

gulp.task 'vendor',
  gulp.series(
    cleanVendor
    gulp.parallel(compileVendorScripts) # , compileVendorStyles)
    gulp.parallel(optimizeVendorScripts) # , optimizeVendorStyles)
  )

# Development Workflow ---------------------------------------------------------

watch = ->
  isWatching = true
  gulp.watch "{#{paths.styles.core},#{paths.styles.vendor},#{paths.styles.website}}/**/*", gulp.series(compileStyles)
  gulp.watch "{#{paths.scripts.core},#{paths.scripts.vendor}}/**/*", gulp.series(compileScripts)
  gulp.watch "{#{paths.assets.base}}/**/*", gulp.series(compileAssets)
  gulp.watch "{#{paths.website.base}}/**/*", gulp.series(compileWebsite)

serve = ->
  server = plugins.liveServer.static(paths.build.website, options.liveServer.port)
  server.start()

  gulp.watch "#{paths.build.base}/**/*.{css,js,png,svg,html}", (file) ->
    server.notify.apply server, [ file ]

# Website ----------------------------------------------------------------------

cleanWebsite = ->
  del paths.build.website

compileWebsite = ->
  # TODO: Replace with a more modern hbs compiler setup
  hbs = require 'express-hbs'
  through = require 'through2'

  plugins.mergeStream(
    gulp.src "#{paths.website.base}/**/**/*.html"
      .pipe through.obj (file, enc, cb) ->
        render = hbs.create().express3
          viewsDir: paths.website.base
          partialsDir: paths.website.partials
          layoutDir: paths.website.layouts
          defaultLayout: "#{paths.website.layouts}/default.html"
          extName: 'html'
        locals = {
          settings: {
            views: paths.website.base
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

    # Copy Website Images
    gulp.src "#{paths.website.base}/images/**/*"
      .pipe gulp.dest("#{paths.build.website}/images")

    # Symlink Styles and Scripts
    # TODO: Make the server support serving from these paths without symlinks
    gulp.src paths.build.styles
      .pipe plugins.symlink("#{paths.build.website}/styles", force: true)
    gulp.src paths.build.scripts
      .pipe plugins.symlink("#{paths.build.website}/scripts", force: true)
  )

# Distribution -----------------------------------------------------------------

cleanDistribution = ->
  del "#{paths.distribution.base}/#{pkg.version}"

cleanAllDistributions = ->
  del paths.distribution.base

createDistribution = ->

  # Copy Website to Distribution Output
  gulp.src "#{paths.build.website}/**/*"
    .pipe gulp.dest("#{paths.distribution.base}/#{pkg.version}")

# Tests ------------------------------------------------------------------------

cleanTests = ->
  del paths.build.tests

compileTests = ->
  gulp.src "#{paths.tests.base}/**/*.coffee"
    .pipe plugins.coffee(bare: true)
    .pipe gulp.dest(paths.build.tests)

runTests = ->
  gulp.src "#{paths.build.tests}/**/*.spec.js"
    .pipe plugins.karmaRunner.server(
      'singleRun': true
      'frameworks': [ 'jasmine' ]
      'browsers': [ 'PhantomJS' ]
      'reporters': [ 'verbose' ]
      files: [
        "#{paths.build.scripts}/vendor/**/*.js"
        "#{paths.build.scripts}/cyclops.js"
        "#{paths.build.tests}/helpers/**/*.js"
        "#{paths.build.tests}/**/*.spec.js"
      ]
    )

runTestsInBrowsers = ->
  gulp.src "#{paths.build.tests}/**/*.spec.js"
    .pipe plugins.karmaRunner.server(
      'singleRun': false
      'frameworks': [ 'jasmine' ]
      'browsers': [ 'PhantomJS', 'Chrome', 'Safari', 'Firefox' ]
      'reporters': [ 'verbose', 'kjhtml' ]
      files: [
        "#{paths.build.scripts}/vendor/**/*.js"
        "#{paths.build.scripts}/cyclops.js"
        "#{paths.build.tests}/helpers/**/*.js"
        "#{paths.build.tests}/**/*.spec.js"
      ]
    )

# Tasks ------------------------------------------------------------------------

gulp.task 'clean', gulp.series(cleanAssets, cleanScripts, cleanStyles, cleanVendor, cleanWebsite, cleanTests, cleanDistribution)

gulp.task 'compile', gulp.series('clean', compileAssets, gulp.parallel(compileVendorScripts, compileScripts, compileStyles), compileWebsite)

gulp.task 'test', gulp.series('compile', compileTests, runTests)

gulp.task 'test-browsers', gulp.series('compile', compileTests, runTestsInBrowsers)

gulp.task 'optimize', gulp.series('compile', optimizeAssets, gulp.parallel(optimizeVendorScripts, optimizeScripts, optimizeStyles, optimizeVendorScripts))

gulp.task 'dist', gulp.series('optimize', createDistribution)

gulp.task 'watch', gulp.series('compile', watch)

gulp.task 'serve', gulp.parallel('watch', serve)

gulp.task 'default', gulp.series('serve')

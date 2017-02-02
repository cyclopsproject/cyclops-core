//
// # Cyclops Build Script
//
// Provides the tasks for building, testing and distributing the Cyclops project
// through the use of Gulp.
//
// ## Tasks
//
//   * `gulp serve` (or `npm start`) will start the development server and watch
//     for changes to files in the src folder.
//
//   * `gulp compile` will compile all of the assets, scripts, styles and
//      website into the `build` folder. The website may be viewed by opening
//      the `build/website/index.html` file.
//
//   * `gulp test` (or `npm test`) will run through our automated test suite in
//     a headless browser (PhantomJS) and report the results on the console.
//
//   * `gulp test-browsers` will run through our automated test suite, just like
//     `gulp test`, but it will run the suite in all of the installed browsers
//     on your machine in addition to PhantomJS.
//
//   * `gulp distribute` will compile, optimize and package Cyclops for
//     distribution in the `dist` folder.
//
//   * `gulp release` will compile, optimize and package Cyclops for release
//     in the `releases` folder. The current version in `package.json` will be
//     used as the name of its containing folder in `releases`.
//

// Dependencies ----------------------------------------------------------------

import autoprefixer from 'gulp-autoprefixer';
import babel from 'gulp-babel';
import cleanCss from 'gulp-clean-css';
import concat from 'gulp-concat';
import del from 'del';
import eventStream from 'event-stream';
import gulp from 'gulp';
import hbs from 'express-hbs';
import inject from 'gulp-inject';
import karmaRunner from 'gulp-karma-runner';
import liveServer from 'gulp-live-server';
import mergeStream from 'merge-stream';
import notifier from 'node-notifier';
import plumber from 'gulp-plumber';
import rename from 'gulp-rename';
import sass from 'gulp-sass';
import sourcemaps from 'gulp-sourcemaps';
import streamqueue from 'streamqueue';
import svgmin from 'gulp-svgmin';
import svgstore from 'gulp-svgstore';
import through from 'through2';
import uglify from 'gulp-uglify';

var pkg = require('./package.json');

// Configuration ---------------------------------------------------------------

var isWatching = false;

const paths = {
  scripts: {
    build: 'src/build',
    core: 'src/scripts',
    vendor: 'vendor/scripts',
    website: 'src/website/styles'
  },
  styles: {
    core: 'src/styles',
    vendor: 'vendor/styles',
    website: 'src/website/styles'
  },
  assets: {
    base: 'src/assets',
    fonts: 'src/assets/fonts',
    icons: 'src/assets/images/icons',
    images: 'src/assets/images'
  },
  website: {
    base: 'src/website',
    partials: 'src/website/partials',
    layouts: 'src/website/layouts'
  },
  tests: {
    base: 'spec',
    helpers: 'spec/helpers'
  },
  build: {
    base: 'build',
    assets: 'build/assets',
    styles: 'build/styles',
    scripts: 'build/scripts',
    images: 'build/assets/images',
    icons: 'build/assets/images/icons',
    website: 'build/website',
    tests: 'build/tests'
  },
  distribution: {
    base: 'dist'
  },
  releases: {
    base: 'releases'
  }
};

const options = {
  autoprefixer: {
    browsers: [ 'ie >= 9', 'last 2 versions' ],
    cascade: false
  },
  babel: {
    plugins: [ 'transform-es2015-modules-umd' ],
    presets: [ 'latest']
  },
  sass: {
    includePaths: [ `${__dirname}/${paths.styles.core}`, `${__dirname}/${paths.styles.website}` ]
  },
  liveServer: {
    port: process.env.PORT || 4300
  },
  plumber: {
    errorHandler: function(error) {
      if (isWatching) {
        console.error(error.stack);
        return notifier.notify({
          title: 'Cyclops Core Error',
          message: error.message,
          contentImage: `${__dirname}/${paths.assets.images}/cyclops.png`,
          sound: true
        });
      } else {
        throw error;
      }
    }
  },
  webpack: {
    module: {
      loaders: [
        {
          loader: 'babel-loader'
        }
      ]
    }
  }
};

// Helpers ---------------------------------------------------------------------

function appendStream() {
  let pass = through.obj();
  return eventStream.duplex(pass, streamqueue({
    objectMode: true
  }, pass, arguments[0]));
};

// Assets ----------------------------------------------------------------------

export function cleanAssets() {
  return del(paths.build.assets);
};

export function compileAssets(done) {
  return done();
};

export function optimizeAssets(done) {
  return done();
};

// Scripts ---------------------------------------------------------------------

function cleanScripts() {
  return del(paths.build.scripts);
};

function compileScripts() {
  // inline icons SVGs
  // TODO: Move to assets tasks
  // svgs = gulp.src "#{paths.assets.icons}/**/*.svg"
  //   .pipe rename(prefix: 'icon-')
  //   .pipe svgmin()
  //   .pipe svgstore(inlineSvg: true)
  //
  // afterFile = gulp.src "#{paths.scripts.build}/after.js"
  //   .pipe inject(svgs, {
  //     name: 'icons',
  //     transform: (filePath, file) ->
  //       return file.contents.toString().replace(/"/g, '\\"')
  //    })

  return gulp.src(`${paths.scripts.core}/**/*.js`)
    .pipe(sourcemaps.init())
    .pipe(babel(options.babel))
    .pipe(concat('cyclops.core.js'))
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest(paths.build.scripts));

  // return mergeStream svgs, afterFile, coffeeScriptFiles
};

function compileVendorScripts() {
  return mergeStream(
    gulp.src(paths.scripts.vendor + "/**/*.js")
      .pipe(sourcemaps.init())
      .pipe(sourcemaps.write('.'))
      .pipe(gulp.dest(paths.build.scripts + "/vendor")));
};

function concatenateVendorScripts() {
  let scriptsToConcatenate = [ `${paths.build.scripts}/vendor/**/*.js`, `!${paths.build.scripts}/vendor/**/*.min.js` ];
  return gulp.src(scriptsToConcatenate)
    .pipe(sourcemaps.init())
    .pipe(concat('cyclops.vendor.js'))
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest(paths.build.scripts));
};

function concatenateScripts() {
  let scriptsToConcatenate = [ `${paths.build.scripts}/cyclops.core.js` ];
  return gulp.src(scriptsToConcatenate)
    .pipe(sourcemaps.init())
    .pipe(concat('cyclops.js'))
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest(paths.build.scripts));
};

function optimizeScripts() {
  return gulp.src([ `${paths.build.scripts}/**/*.js`, `!${paths.build.scripts}/**/*.min.js` ])
    .pipe(plumber(options.plumber))
    .pipe(sourcemaps.init())
    .pipe(uglify())
    .pipe(rename({ suffix: '.min' }))
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest(paths.build.scripts));
};

// Stylesheets -----------------------------------------------------------------

function cleanStyles() {
  return del(paths.build.styles);
};

function compileStyles() {
  return gulp.src([ `${paths.styles.core}/cyclops.scss`, `${paths.styles.website}/site.scss` ])
    .pipe(plumber(options.plumber))
    .pipe(sourcemaps.init())
    .pipe(sass(options.sass))
    .pipe(autoprefixer(options.autoprefixer))
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest(paths.build.styles));
};

function compileVendorStyles(done) {
  return done();
};

function concatenateVendorStyles(done) {
  return done();
};

function concatenateStyles(done) {
  return done();
};

function optimizeStyles() {
  return gulp.src([ `${paths.build.styles}/**/*.css`, `!${paths.build.styles}/**/*.css` ])
    .pipe(sourcemaps.init())
    .pipe(cleanCss())
    .pipe(rename({ suffix: '.min' }))
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest(paths.build.styles));
};

// Development Workflow --------------------------------------------------------

function watchForChanges() {
  isWatching = true;
  gulp.watch(`{${paths.styles.core},${paths.styles.vendor},${paths.styles.website}}/**/*`, gulp.series(compileStyles, compileVendorStyles, concatenateVendorStyles));
  gulp.watch(`{${paths.scripts.core},${paths.scripts.vendor}}/**/*`, gulp.series(compileVendorScripts, compileScripts, concatenateVendorScripts, concatenateScripts));
  gulp.watch(`${paths.assets.base}/**/*`, compileAssets);
  gulp.watch(`${paths.website.base}/**/*`, compileWebsite);
};

function runWebServer() {
  let server = liveServer["static"](paths.build.website, options.liveServer.port);
  server.start();
  gulp.watch(`${paths.build.base}/**/*.{css,js,png,svg,html}`, function(file) {
    server.notify.apply(server, [file]);
  });
};

// Website ---------------------------------------------------------------------

function cleanWebsite() {
  return del(paths.build.website);
};

function compileWebsite() {
  return mergeStream(

    gulp.src(`${paths.website.base}/**/**/*.html`)
      .pipe(through.obj(function(file, enc, cb) {
        let render = hbs.create().express3({
          viewsDir: paths.website.base,
          partialsDir: paths.website.partials,
          layoutDir: paths.website.layouts,
          defaultLayout: paths.website.layouts + "/default.html",
          extName: 'html'
        });
        let locals = {
          settings: {
            views: paths.website.base
          },
          version: pkg.version
        };
        return render(file.path, locals, (function(_this) {
          return function(err, html) {
            if (!err) {
              file.contents = new Buffer(html);
              _this.push(file);
              return cb();
            } else {
              console.log('failed to render #{file.path}');
              return console.log(err);
            }
          };
        })(this));
      }))
    .pipe(gulp.dest(paths.build.website)),

    // Copy Website Images
    gulp.src(`${paths.website.base}/images/**/*`)
      .pipe(gulp.dest(paths.build.website + "/images")),

    // Symlink Styles and Scripts
    // TODO: Make the server support serving from these paths without symlinks
    gulp.src(paths.build.styles)
      .pipe(gulp.symlink(`${paths.build.website}`)),
    gulp.src(paths.build.scripts)
      .pipe(gulp.symlink(`${paths.build.website}`))

  );
};

// Distribution ----------------------------------------------------------------

function cleanDistribution() {
  return del(paths.distribution.base);
};

function createDistribution() {
  return mergeStream(

    // Copy Website to Distribution Output
    gulp.src(`${paths.build.website}/**/*`)
      .pipe(gulp.dest(paths.distribution.base)),

    // Concatenate Scripts
    gulp.src(paths.build.scripts)
      .pipe(sourcemaps.init())
      .pipe(concat('cyclops.js'))
      .pipe(sourcemaps.write('.')),

    // Concatenate Styles
    gulp.src(paths.build.styles)

  );
};

// Release ----------------------------------------------------------------

function cleanRelease() {
  return del(`${paths.releases.base}/${pkg.version}`);
};

function cleanAllReleases() {
  return del(paths.releases.base);
};

function createRelease() {

  // Copy Distribution Output to Versioned Release Folder
  return gulp.src(`${paths.distribution.base}/**/*`)
    .pipe(gulp.dest(`${paths.releases.base}/${pkg.version}`));

};

// Tests -----------------------------------------------------------------------

function cleanTests() {
  return del(paths.build.tests);
};

function compileTests() {
  return gulp.src(`${paths.tests.base}/**/*.js`)
    .pipe(babel(options.babel))
    .pipe(gulp.dest(paths.build.tests));
};

function runTests() {
  return gulp.src(`${paths.tests.base}/**/*.spec.js`)
    .pipe(karmaRunner.server({
      singleRun: true,
      frameworks: [ 'jasmine' ],
      browsers: [ 'PhantomJS' ],
      reporters: [ 'verbose' ],
      preprocessors: {
				'spec/**/*.spec.js': [ 'webpack' ],
        'src/**/*.js': [ 'webpack' ]
			},
      webpack: options.webpack
  }));
};

function runTestsInBrowsers() {
  return gulp.src(`${paths.tests.base}/**/*.spec.js`)
    .pipe(karmaRunner.server({
      'singleRun': false,
      'frameworks': [ 'jasmine' ],
      'browsers': [ 'PhantomJS', 'Chrome', 'Safari', 'Firefox' ],
      'reporters': [ 'verbose', 'kjhtml' ],
      preprocessors: {
        'spec/**/*.spec.js': [ 'webpack' ],
        'src/**/*.js': [ 'webpack' ]
      },
      webpack: options.webpack
  }));
};

// Tasks ------------------------------------------------------------------------

const clean = gulp.series(cleanAssets, cleanScripts, cleanStyles, cleanTests, cleanWebsite);
const compile = gulp.series(clean, gulp.parallel(compileAssets, compileVendorScripts, compileScripts, compileVendorStyles, compileStyles), concatenateVendorScripts, concatenateScripts, concatenateVendorStyles, concatenateStyles, compileWebsite);
const test = gulp.series(compile, compileTests, runTests);
const testBrowsers = gulp.series(compile, compileTests, runTestsInBrowsers);
const optimize = gulp.series(compile, gulp.parallel(optimizeAssets, optimizeScripts, optimizeStyles));
const distribute = gulp.series(optimize, cleanDistribution, createDistribution);
const release = gulp.series(distribute, cleanRelease, createRelease);
const serve = gulp.series(compile, gulp.parallel(watchForChanges, runWebServer));

export {
  clean, compile, distribute, optimize, release, serve, test, testBrowsers
};

export default serve;

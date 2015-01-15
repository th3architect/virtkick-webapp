var fs = require('fs');
var YAML = require('js-yaml');
var extend = require('extend');
module.exports = function(grunt) {

  var requirejsConfig = YAML.safeLoad(fs.readFileSync('./config/requirejs.yml', 'utf8'));

  // Project configuration.
  grunt.initConfig({
    options: {

    },
    requirejs: {
      options: {
        optimize: grunt.option("debug") ? "none" : "uglify"
      },
      std: {
        options: extend(requirejsConfig, {
          appDir: './app/javascripts',
          baseUrl: '.',
          paths: {
            app: './',
          },
          dir: './public/javascripts',
          onBuildRead: function (moduleName, path, contents) { return require('ng-annotate')(contents, {add: true}).src;},
          pragmasOnSave: {
            excludeJade: true
          }
        })
      }
    }
  });

  grunt.loadNpmTasks("grunt-contrib-requirejs");
  grunt.registerTask('build', ['requirejs:std']);
};
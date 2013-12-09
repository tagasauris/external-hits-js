module.exports = (grunt) ->

  grunt.initConfig
    clean:
      all: ['./lib/', './tmp/']
      tmp: ['./tmp/']
    includes:
      app:
        cwd: 'src'
        src: [
          'parent.coffee',
          'child.coffee'
        ]
        dest: 'tmp'
    coffee:
      tmp:
        expand: true
        cwd: 'tmp'
        src: ['**/*.coffee']
        dest: 'lib'
        ext: '.js'
    uglify:
      lib:
        files:
          'lib/parent.min.js': ['lib/parent.js']
          'lib/child.min.js': ['lib/child.js']
    watch:
      compile:
        files: '**/*.coffee'
        tasks: ['compile']
      build:
        files: '**/*.coffee'
        tasks: ['build']
    coffeelint:
      options:
        max_line_length:
          level: 'warn'
      app: ['src/**/*.coffee']


  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-includes'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-coffeelint'


  grunt.registerTask 'minify', [
    'uglify:lib'
  ]

  grunt.registerTask 'compile', [
    'coffeelint:app',
    'includes',
    'coffee:tmp',
  ]

  grunt.registerTask 'build', [
    'clean:all',
    'compile',
    'clean:tmp',
    'minify'
  ]

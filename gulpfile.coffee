configs =
  __dirname : __dirname

configs.templateCache = []

configs.templateCache.push
  fileName: 'example-templates.js'
  files : [
    '.tmp/views/ng-auth.html'
  ]
  root  : 'views/'
  module: 'example'

### END CONFIG ###
loadTasksModule = require __dirname + '/node_modules/appirio-gulp-tasks/load-tasks.coffee'

loadTasksModule.loadTasks configs

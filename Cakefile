{spawn} = require 'child_process'
puts = console.log

system = (name, args) ->
    proc = spawn name, args, stdio: 'inherit'

compileall = (from, to, watch = false) ->
    args = ['--map', '-o', to, '-c', from]
    args.unshift '--watch' if watch
    system 'coffee', args 

task 'c', 'Compile and watch', ->
    compileall 'lib/', 'docs/', true

task 'compile', 'Compile', ->
    puts "Compiling..."
    compileall 'lib/', 'docs/'

task 'server', 'Serve the current filesystem. Needed for loading textures from fs.
Require python installed.', ->
    system 'python3', '-m http.server'.split(' ')


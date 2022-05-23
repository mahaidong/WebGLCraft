class @Instructions
    constructor: (@callback) ->
        @domElement = $('#instructions')

    instructions:
        leftclick: "Remove block"
        rightclick: "Add block"
        drag: "Drag with the left mouse clicked to move the camera"
        save: "Save map"
        pause: "Pause/Unpause"
        space: "Jump"
        wasd: "WASD keys to move"
        scroll: "Scroll to change selected block"

    intructionsBody: ->
        @domElement.append "<div id='instructionsContent'>
                                         <h1>Click to start</h1>
                                         <table>#{@lines()}</table>
                                         </div>"
        $("#instructionsContent").mousedown =>
            @domElement.hide()
            @callback()
        return

    insert: ->
        @setBoder()
        @intructionsBody()
        @domElement.show()

    lines: ->
        ret = (@line(inst) for inst of @instructions)
        ret.join(' ')

    line: (name) ->
        inst = @instructions[name]
        "<tr><td class='image'>#{@img(name)}</td>
                      <td class='label'>#{inst}</td></tr>"

    setBoder: ->
        for prefix in ['-webkit-', '-moz-', '-o-', '-ms-', '']
            @domElement.css prefix + 'border-radius', '10px'
        return

    img: (name) -> "<img src='./instructions/#{name}.png'/>"


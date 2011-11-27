# Imports
{Object3D, Matrix4, Scene, Mesh, WebGLRenderer, PerspectiveCamera} = THREE
{CubeGeometry, PlaneGeometry, MeshLambertMaterial, MeshNormalMaterial} = THREE
{AmbientLight, DirectionalLight, PointLight, Ray, Vector3, Vector2} = THREE
{MeshLambertMaterial, MeshNormalMaterial} = THREE
{Texture, UVMapping, RepeatWrapping, RepeatWrapping, NearestFilter} = THREE
{LinearMipMapLinearFilter, ClampToEdgeWrapping} = THREE

vec = (x, y, z) -> new Vector3 x, y, z

CubeSize = 50

class Player
    width: CubeSize * 0.3
    depth: CubeSize * 0.3
    height: CubeSize * 1.63

    constructor: ->
        @halfHeight = @height / 2
        @halfWidth = @width / 2
        @halfDepth = @depth / 2
        @pos = vec 850, 300, 35
        @_cube = @_createCube()
        @eyesDelta = @halfHeight * 0.9

    #todo: remove
    showCube: -> @_cube.position = @pos.clone()

    eyesPosition: ->
        ret = @pos.clone()
        ret.y += @eyesDelta
        return ret


    position: (axis) ->
        return @pos unless axis?
        return @pos[axis]

    incPosition: (axis, val) ->
        @pos[axis] += val
        return

    setPosition: (axis, val) ->
        @pos[axis] = val
        return

    addToScene: (scene) -> scene.add @_cube

    collidesWithGround: -> @position('y') < @halfHeight

    vertex: (vertexX, vertexY, vertexZ) ->
        vertex = @position().clone()
        vertex.x += vertexX * @halfWidth
        vertex.y += vertexY * @halfHeight
        vertex.z += vertexZ * @halfDepth
        return vertex

    boundingBox: ->
        vmin = @vertex(-1, -1, -1)
        vmax = @vertex 1, 1, 1
        return {vmin: vmin, vmax: vmax}

    _directionLength: (direction) ->
        return @width if direction.x != 0
        return @height if direction.y != 0
        return @depth if direction.z != 0
        raise "Invalid Direction: 0, 0 ,0"


    _createCube: ->
        geo = new CubeGeometry(@width, @height, @depth)
        cube = new Mesh(geo, new MeshNormalMaterial())
        cube.geometry.dynamic = true
        cube.position.set 850, 300, 35
        cube.name = "player"
        cube

    _getClosest: (intersections) ->
        for i in intersections
            return i unless i.object.name in ['player', 'floor']
        return


class Grid
    constructor: (@size) ->
        @size or= 5
        @matrix = []
        @size.times (i) =>
            @matrix[i] = []
            @size.times (j) =>
                @matrix[i][j] = []

    get: (x, y, z) -> @matrix[x][y][z]

    put: (x, y, z, val) -> @matrix[x][y][z] = val


class CollisionHelper
    constructor: (@player, @grid)-> return
    rad: CubeSize
    halfRad: CubeSize / 2

    collides: ->
        return true if @player.collidesWithGround()
        playerBox = @player.boundingBox()
        for cube in @possibleCubes()
            return true if @collideWithCube playerBox, cube
        return false

    _addToPosition: (position, value) ->
        pos = position.clone()
        pos.x += value
        pos.y += value
        pos.z += value
        return pos

    collideWithCube: (playerBox, cube) ->
        vmin = @_addToPosition cube.position, -@halfRad
        vmax = @_addToPosition cube.position, @halfRad
        cubeBox = {vmin, vmax}
        return CollisionUtils.testCubeCollision playerBox, cubeBox

    possibleCubes: ->
        cubes = []
        grid = @grid
        @withRange (x, y, z) ->
            cube = grid.get x, y, z
            cubes.push cube if cube?
        return cubes

    withRange: (func) ->
        {vmin, vmax} = @player.boundingBox()
        minx = @toGrid(vmin.x)
        miny = @toGrid(vmin.y)
        minz = @toGrid(vmin.z)

        maxx = @toGrid(vmax.x) + 1
        maxy = @toGrid(vmax.y) + 1
        maxz = @toGrid(vmax.z) + 1
        x = minx
        while x <= maxx
            y = miny
            while y <= maxy
                z = minz
                while z <= maxz
                    func x, y, z
                    z++
                y++
            x++
        return

    toGrid: (val) ->
        ret = Math.floor(val / @rad)
        return 0 if ret < 0
        return @grid.size if ret > @grid.size
        return ret


TextureHelper =
    loadTexture: (path) ->
        image = new Image()
        image.src = path
        texture = new Texture(image, new UVMapping(), ClampToEdgeWrapping, ClampToEdgeWrapping, NearestFilter, LinearMipMapLinearFilter)
        image.onload = -> texture.needsUpdate = true
        new THREE.MeshLambertMaterial(map: texture, ambient: 0xbbbbbb)


    tileTexture: (path, repeatx, repeaty) ->
        image = new Image()
        image.src = path
        texture = new Texture(image, new UVMapping(), RepeatWrapping,
        RepeatWrapping, NearestFilter, LinearMipMapLinearFilter)
        texture.repeat.x = repeatx
        texture.repeat.y = repeaty
        image.onload = -> texture.needsUpdate = true
        new THREE.MeshLambertMaterial(map: texture, ambient: 0xbbbbbb)



class Floor
    constructor: (width, height) ->
        repeatX = width / CubeSize
        repeatY = height / CubeSize
        material = TextureHelper.tileTexture("./textures/bedrock.png", repeatX, repeatY)
        planeGeo = new PlaneGeometry(width, height, 1, 1)
        plane = new Mesh(planeGeo, material)
        plane.position.y = -1
        plane.rotation.x = -Math.PI / 2
        plane.name = 'floor'
        @plane = plane

    addToScene: (scene) -> scene.add @plane


class Game
    constructor: ->
        @rad = CubeSize
        # @geo = new CubeGeometry(@rad, @rad, @rad, 1, 1, 1)
        @width = window.innerWidth
        @height = window.innerHeight

        grass_dirt = TextureHelper.loadTexture "./textures/grass_dirt.png"
        grass = TextureHelper.loadTexture "./textures/grass.png"
        dirt = TextureHelper.loadTexture "./textures/dirt.png"
        materials = [grass_dirt, #right
            grass_dirt, # left
            grass, # top
            dirt, # bottom
            grass_dirt, # back
            grass_dirt]  #front
        @geo = new THREE.CubeGeometry( @rad, @rad, @rad, 1, 1, 1, materials)

        @mat = new MeshLambertMaterial(color: 0xCC0000)
        @move = {x: 0, z: 0, y: 0}
        @keysDown = {}
        @grid = new Grid(200)
        @onGround = true
        @pause = off
        @renderer = @createRenderer()
        @camera = @createCamera()
        @controls = new Controls @camera, @renderer.domElement
        @player = new Player()
        @scene = new Scene()
        @player.addToScene @scene
        new Floor(50000, 50000).addToScene @scene
        @scene.add @camera
        @populateWorld()
        @addLights @scene
        @renderer.render @scene, @camera
        @defineControls()


    posFromGrid: (position) ->
        {x, y, z} = position
        return @fromGrid x, y, z

    fromGrid: (x, y, z) ->
        return @grid.get @gridCoords(x, y, z)...

    gridCoords: (x, y, z) ->
        x = Math.floor(x / @rad)
        y = Math.floor(y / @rad)
        z = Math.floor(z / @rad)
        return [x, y, z]

    intoGrid: (x, y, z, val) ->
        args = @gridCoords(x, y, z).concat(val)
        return @grid.put args...

    populateWorld: ->
        size = 5
        halfSize = CubeSize / 2
        for i in [0..(2 * size)]
            for j in [0..(2 * size)]
                @cubeAt (4 * CubeSize) + @rad * i, halfSize, @rad * j

        for i in [size..(2*size)]
            for j in [size..(2*size)]
                @cubeAt 4 * CubeSize + @rad * i, CubeSize * 1.5, @rad * j

        for i in [size..(2*size)]
            for j in [size..(2*size)]
                @cubeAt 4 * CubeSize + @rad * i, CubeSize * 4.5, @rad * j

        for i in [0..10]
            @cubeAt (15 * CubeSize) + i * CubeSize, CubeSize * 1.5 + i * CubeSize, CubeSize


    cubeAt: (x, y, z) ->
        mesh = new Mesh(@geo, new THREE.MeshFaceMaterial())
        mesh.geometry.dynamic = false
        mesh.position.set x, y, z
        mesh.name = "world block"
        @intoGrid x, y, z, mesh
        @scene.add mesh
        mesh.updateMatrix()
        mesh.matrixAutoUpdate = false


    createCamera: ->
        camera = new PerspectiveCamera(45, @width / @height, 1, 10000)
        camera.position.set 1500, 400, 800
        camera.lookAt vec 0, 0, 0
        camera

    createRenderer: ->
        renderer = new WebGLRenderer(antialias: true)
        renderer.setSize @width, @height
        renderer.setClearColorHex(0xBFD1E5, 1.0)
        renderer.clear()
        $('#container').append(renderer.domElement)
        renderer

    addLights: (scene) ->
        ambientLight = new AmbientLight(0xcccccc)
        scene.add ambientLight
        directionalLight = new DirectionalLight(0xffffff, 1.5)
        directionalLight.position.set 1, 1, 0.5
        directionalLight.position.normalize()
        scene.add directionalLight

    cameraKeys:
        8: 'z-'
        5: 'z+'
        4: 'x-'
        6: 'x+'
        7: 'y+'
        9: 'y-'

    _setBinds: (baseVel, keys, incFunction)->
        for key, action of keys
            [axis, operation] = action
            vel = if operation is '-' then -baseVel else baseVel
            $(document).bind 'keydown', key, -> incFunction(axis, vel)

    defineControls: ->
        @_setBinds 30, @cameraKeys, (axis, vel) =>
            @camera.position[axis] += vel
        for key in "wasd".split('').concat('space')
            $(document).bind 'keydown', key, => @keysDown[key] = true
            $(document).bind 'keyup', key, => @keysDown[key] = false
        $(document).bind 'keydown', 'p', => @pause = !@pause
        #todo: remove
        $(document).bind 'keydown', 'r', => @player.showCube()


    collides: -> new CollisionHelper(@player, @grid).collides()

    start: ->
        animate = =>
            @tick() unless @pause
            requestAnimationFrame animate, @renderer.domElement
        animate()

    axes: ['x', 'y', 'z']
    iterationCount: 10

    # tries to move the cube in the axis. returns true if and only if it doesn't collide
    moveCube: (axis) ->
        iterationCount = @iterationCount
        ivel = {}
        for axis in @axes
            ivel[axis] = @move[axis] / @iterationCount
        while iterationCount-- > 0
            for axis in @axes when ivel[axis] isnt 0
                originalpos = @player.position(axis)
                @player.incPosition axis, ivel[axis]
                if @collides()
                    @player.setPosition axis, originalpos
                    @touchesGround() if axis is 'y' and ivel.y < 0
                    @move[axis] = 0
                    ivel[axis] = 0
        return

    touchesGround: ->
        @onGround = true

    playerKeys:
        w: 'z+'
        s: 'z-'
        a: 'x+'
        d: 'x-'

    shouldJump: -> @keysDown.space and @onGround and @move.y == 0

    defineMove: ->
        baseVel = 7
        jumpSpeed = 12
        @move.x = 0
        @move.z = 0
        for key, action of @playerKeys
            [axis, operation] = action
            vel = if operation is '-' then -baseVel else baseVel
            @move[axis] += vel if @keysDown[key]
        if @shouldJump()
            @onGround = false
            @move.y += jumpSpeed
        @projectMoveOnCamera()
        @applyGravity()
        return

    projectMoveOnCamera: ->
        {x, z} = @controls.viewDirection()
        frontDir = new Vector2(x, z).normalize()
        rightDir = new Vector2(frontDir.y, -frontDir.x)
        frontDir.multiplyScalar @move.z
        rightDir.multiplyScalar @move.x
        @move.x = frontDir.x + rightDir.x
        @move.z = frontDir.y + rightDir.y


    applyGravity: -> @move.y -= 1 unless @move.y < -20

    setCameraEyes: ->
        pos = @player.eyesPosition()
        @controls.move pos
        eyesDelta = @controls.viewDirection().normalize().multiplyScalar(20)
        eyesDelta.y = 0
        pos.subSelf eyesDelta
        return


    tick: ->
        raise "Cube is way below ground level" if @player.position 'y' < 0
        @defineMove()
        @moveCube()
        @renderer.clear()
        @controls.update()
        unless @thirdPerson
            @setCameraEyes()
        else
            @player.showCube()
        @renderer.render @scene, @camera
        # @debug()
        return

    debug: ->
        for axis in @axes
            $('#pos' + axis).html String @player.position axis
        return



init_web_app = -> new Game().start()

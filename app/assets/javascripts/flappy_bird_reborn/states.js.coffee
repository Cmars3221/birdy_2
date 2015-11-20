# 'Flappy Bird Reborn'
#
# last update: 2014.04.16.
#

# States
#
@States = {
  # boot state
  Boot: class Boot extends Phaser.State
    preload: ->
      @load.image('preloader', '/flappy_bird_reborn/images/preloader.gif')

      return

    create: ->
      @game.input.maxPointers = 1
      @game.state.start('preload')

      return

  # preload state
  Preload: class Preload extends Phaser.State
    constructor: ->
      @asset = null
      @ready = false

    preload: ->
      @asset = @add.sprite(@width / 2, @height / 2, 'preloader')
      @asset.anchor.setTo(0.5, 0.5)

      @load.onLoadComplete.addOnce(@onLoadComplete, @)
      @load.setPreloadSprite(@asset)

      @load.image('background', '/flappy_bird_reborn/images/background.png')
      @load.image('ground', '/flappy_bird_reborn/images/ground.png')
      @load.image('title', '/flappy_bird_reborn/images/title.png')
      @load.image('startButton', '/flappy_bird_reborn/images/start-button.png')
      @load.image('instructions', '/flappy_bird_reborn/images/instructions.png')
      @load.image('getReady', '/flappy_bird_reborn/images/get-ready.png')

      @load.image('scoreboard', '/flappy_bird_reborn/images/scoreboard.png')
      @load.image('gameover', '/flappy_bird_reborn/images/gameover.png')
      @load.image('particle', '/flappy_bird_reborn/images/particle.png')

      @load.spritesheet('bird', '/flappy_bird_reborn/images/bird.png', 34, 24, 3)
      @load.spritesheet('pipe', '/flappy_bird_reborn/images/pipes.png', 54, 320, 2)
      @load.spritesheet('medals', '/flappy_bird_reborn/images/medals.png', 44, 46, 2)

      @load.bitmapFont('flappyfont', '/flappy_bird_reborn/fonts/flappyfont.png', '/flappy_bird_reborn/fonts/flappyfont.fnt')

      @load.audio('score', '/flappy_bird_reborn/sounds/score.wav')
      @load.audio('flap', '/flappy_bird_reborn/sounds/flap.wav')
      @load.audio('pipeHit', '/flappy_bird_reborn/sounds/pipe-hit.wav')
      @load.audio('groundHit', '/flappy_bird_reborn/sounds/ground-hit.wav')

      return

    create: ->
      @asset.cropEnabled = false

      return

    update: ->
      if @ready
        @game.state.start('menu')

      return

    onLoadComplete: ->
      @ready = true

      return

  # menu state
  Menu: class Menu extends Phaser.State
    create: ->
      # add the background sprite
      @background = @game.add.sprite(0, 0, 'background')

      # add the ground sprite as a tile and start scrolling in the negative x direction
      @ground = @game.add.tileSprite(0, 400, 335, 112, 'ground')
      @ground.autoScroll(-200, 0)

      # create a group to put the title assets in so they can be manipulated as a whole
      @titleGroup = @game.add.group()

      # create the title sprite and add it to the group
      @title = @add.sprite(0, 0, 'title')
      @titleGroup.add(@title)

      # create the bird sprite and add it to the title group
      @bird = @add.sprite(200, 5, 'bird')
      @titleGroup.add(@bird)

      # add an animation to the bird and begin the animation
      @bird.animations.add('flap')
      @bird.animations.play('flap', 12, true)

      # set the originating location of the group
      @titleGroup.x = 30
      @titleGroup.y = 100

      # create an oscillating animation tween for the group
      @game.add.tween(@titleGroup).to({y: 115}, 350, Phaser.Easing.Linear.NONE, true, 0, 1000, true)

      # add a start button with a callback
      @startButton = @game.add.button(@game.width / 2, 300, 'startButton', @clickStart, @)
      @startButton.anchor.setTo(0.5, 0.5)

      return

    # start button click handler
    clickStart: ->
      # start the 'play' state
      @game.state.start('play')

      return

  # play state
  Play: class Play extends Phaser.State
    create: ->
      @game.physics.startSystem(Phaser.Physics.ARCADE)

      # give our world an initial gravity
      @game.physics.arcade.gravity.y = 1200

      # add the background sprite
      @background = @game.add.sprite(0, 0, 'background')

      # create a new bird object and add it to the game
      @bird = new Sprites.Bird(@game, 100, @game.height / 2)
      @game.add.existing(@bird)

      # create and add a group to hold our pipeGroup prefabs
      @pipes = @game.add.group()

      # create and add a new Ground object
      @ground = new Sprites.Ground(@game, 0, 400, 335, 112)
      @game.add.existing(@ground)

      # create a group for instruction
      @instructionGroup = @game.add.group()
      @instructionGroup.add(@game.add.sprite(@game.width/2, 100, 'getReady'))
      @instructionGroup.add(@game.add.sprite(@game.width/2, 325, 'instructions'))
      @instructionGroup.setAll('anchor.x', 0.5)
      @instructionGroup.setAll('anchor.y', 0.5)

      # keep the spacebar from propogating up to the browser
      @game.input.keyboard.addKeyCapture([Phaser.Keyboard.SPACEBAR])

      # add keyboard controls
      @flapKey = @input.keyboard.addKey(Phaser.Keyboard.SPACEBAR)
      @flapKey.onDown.addOnce(@startGame, @)
      @flapKey.onDown.add(@bird.flap, @bird)

      # add mouse/touch controls
      @game.input.onDown.addOnce(@startGame, @)
      @game.input.onDown.add(@bird.flap, @bird)

      # score text
      @score = 0
      @scoreText = @game.add.bitmapText(@game.width / 2, 10, 'flappyfont', @score.toString(), 24)
      @scoreText.visible = false

      # sounds
      @pipeHitSound = @game.add.audio('pipeHit')
      @groundHitSound = @game.add.audio('groundHit')
      @scoreSound = @game.add.audio('score')

      @gameover = false

      return

    update: ->
      # enable collisions between the bird and the ground
      @game.physics.arcade.collide(@bird, @ground, @deathHandler, null, @)

      unless @gameover
        # enable collisions between the bird and each group in the pipes group
        @pipes.forEach((pipeGroup) ->
          @checkScore(pipeGroup)
          @game.physics.arcade.collide(@bird, pipeGroup, @deathHandler, null, @)
        , @)

      return

    startGame: ->
      if !@bird.alive && !@gameover
        @bird.body.allowGravity = true
        @bird.alive = true

        # add a timer for generating pipes
        @pipeGenerator = @game.time.events.loop(Phaser.Timer.SECOND * 1.25, @generatePipes, @)
        @pipeGenerator.timer.start()

        # remove instruction
        @instructionGroup.destroy()

        @scoreText.visible = true

      return

    generatePipes: ->
      pipeY = @game.rnd.integerInRange(-100, 100)

      # recycle
      pipeGroup = @pipes.getFirstExists(false)
      unless pipeGroup
        pipeGroup = new Groups.Pipe(@game, @pipes)

      pipeGroup.reset(@game.width, pipeY)

      return

    checkScore: (pipeGroup) ->
      if pipeGroup.exists && !pipeGroup.hasScored && pipeGroup.topPipe.world.x <= @bird.world.x
        pipeGroup.hasScored = true
        @score += 1
        @scoreText.setText(@score.toString())
        @scoreSound.play()

      return

    deathHandler: (bird, enemy) ->
      if enemy instanceof Sprites.Ground && !@bird.onGround
        @groundHitSound.play()
        @scoreboard = new Groups.Scoreboard(@game)
        @game.add.existing(@scoreboard)
        @scoreboard.show(@score)
        @bird.onGround = true
      else if enemy instanceof Sprites.Pipe
        @pipeHitSound.play()

      unless @gameover
        @gameover = true
        @bird.kill()
        @pipes.callAll('stop')
        @pipeGenerator.timer.stop()
        @ground.stopScroll()

      return

    shutdown: ->
      @game.input.keyboard.removeKey(Phaser.Keyboard.SPACEBAR)
      @bird.destroy()
      @pipes.destroy()
      @scoreboard.destroy()

      return
}

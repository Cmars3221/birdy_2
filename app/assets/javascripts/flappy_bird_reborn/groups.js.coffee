# 'Flappy Bird Reborn'
#
# last update: 2014.05.16.
#

# Groups
#
@Groups = {
  Pipe: class Pipe extends Phaser.Group
    constructor: (game, parent) ->
      # the super call to Phaser.Group
      super(game, parent)

      @topPipe = new Sprites.Pipe(@game, 0, 0, 0)
      @add(@topPipe)

      @bottomPipe = new Sprites.Pipe(@game, 0, 440, 1)
      @add(@bottomPipe)

      @hasScored = false

      # move this group in x direction
      @setAll('body.velocity.x', -200)

    reset: (x, y) ->
      @topPipe.reset(0, 0)
      @bottomPipe.reset(0, 440)

      @x = x
      @y = y
      
      # move this group in x direction
      @setAll('body.velocity.x', -200)

      @hasScored = false
      @exists = true

      return

    update: ->
      @checkWorldBounds()

      return

    checkWorldBounds: ->
      unless @topPipe.inWorld
        @exists = false

      return

    stop: ->
      @setAll('body.velocity.x', 0)

      return

  Scoreboard: class Scoreboard extends Phaser.Group
    constructor: (game) ->
      # the super call to Phaser.Group
      super(game)

      gameover = @create(@game.width / 2, 100, 'gameover')
      gameover.anchor.setTo(0.5, 0.5)

      @scoreboard = @create(@game.width / 2, 200, 'scoreboard')
      @scoreboard.anchor.setTo(0.5, 0.5)

      @scoreText = @game.add.bitmapText(@scoreboard.width, 180, 'flappyfont', '', 18)
      @add(@scoreText)

      @bestScoreText = @game.add.bitmapText(@scoreboard.width, 230, 'flappyfont', '', 18)
      @add(@bestScoreText)

      # add our start button with a callback
      @startButton = @game.add.button(@game.width / 2, 300, 'startButton', @clickStart, @)
      @startButton.anchor.setTo(0.5, 0.5)
      @add(@startButton)

      @y = @game.height
      @x = 0

    show: (score) ->
      @scoreText.setText(score.toString())

      if localStorage?
        bestScore = localStorage.getItem('bestScore')

        if !bestScore || bestScore < score
          bestScore = score
          localStorage.setItem('bestScore', bestScore)
      else
        bestScore = 'N/A'

      @bestScoreText.setText(bestScore.toString())

      medal = null
      if score >= 10 && score < 20
        medal = @game.add.sprite(-65 , 7, 'medals', 0)  # silver medal
      else if score >= 20
        medal = @game.add.sprite(-65 , 7, 'medals', 1)  # gold medal

      @game.add.tween(@).to({y: 0}, 1000, Phaser.Easing.Bounce.Out, true)

      if medal
        medal.anchor.setTo(0.5, 0.5)
        @scoreboard.addChild(medal)

        # Emitters have a center point and a width/height, which extends from their center point to the left/right and up/down
        emitter = @game.add.emitter(medal.x, medal.y, 400)
        @scoreboard.addChild(emitter)
        emitter.width = medal.width
        emitter.height = medal.height

        emitter.makeParticles('particle')

        emitter.setRotation(-100, 100)
        emitter.setXSpeed(0, 0)
        emitter.setYSpeed(0, 0)
        emitter.minParticleScale = 0.25
        emitter.maxParticleScale = 0.5
        emitter.setAll('body.allowGravity', false)

        emitter.start(false, 1000, 1000)

      return

    clickStart: ->
      # start the 'play' state
      @game.state.start('play')

      return
}

# 'Flappy Bird Reborn'
#
# last update: 2014.04.16.
#

# Sprites
#
@Sprites = {
  # bird sprite
  Bird: class Bird extends Phaser.Sprite
    constructor: (game, x, y, frame) ->
      # the super call to Phaser.Sprite
      super(game, x, y, 'bird', frame)

      # set the sprite's anchor to the center
      @anchor.setTo(0.5, 0.5)

      # add and play animations
      @animations.add('flap')
      @animations.play('flap', 12, true)
      
      # enable physics on the bird and
      # disable gravity on the bird until the game is started
      @game.physics.arcade.enableBody(@)
      @body.allowGravity = false
      @body.collideWorldBounds = true

      # check bounds
      @checkWorldBounds = true
      @outOfBoundsKill = true

      # flap sound
      @flapSound = @game.add.audio('flap')

      @name = 'bird'
      @alive = false
      @onGround = false

      @events.onKilled.add(@onKilled, @)

    flap: ->
      if @alive
        @flapSound.play()

        # cause the bird to "jump" upward
        @body.velocity.y = -400

        # rotate the bird to -40 degrees
        @game.add.tween(@).to({angle: -40}, 100).start()

      return

    update: ->
      # check to see if our angle is less than 90. if it is, rotate the bird towards the ground by 2.5 degrees
      if @angle < 90 && @alive
        @angle += 2.5

      unless @alive
        @body.velocity.x = 0

      return

    onKilled: ->
      @exists = true
      @visible = true
      @animations.stop()
      duration = 90 / @y * 300
      @game.add.tween(@).to({angle: 90}, duration).start()

  # pipe sprite
  Pipe: class Pipe extends Phaser.Sprite
    constructor: (game, x, y, frame) ->
      # the super call to Phaser.Sprite
      super(game, x, y, 'pipe', frame)

      # set the sprite's anchor to the center
      @anchor.setTo(0.5, 0.5)

      # add a physics body
      @game.physics.arcade.enableBody(@)

      @body.allowGravity = false
      @body.immovable = true

  # ground tile sprite
  Ground: class Ground extends Phaser.TileSprite
    constructor: (game, x, y, width, height) ->
      # the super call to Phaser.TileSprite
      super(game, x, y, width, height, 'ground')

      # start scrolling our ground
      @autoScroll(-200, 0)

      # enable physics on the ground sprite, this is needed for collision detection
      @game.physics.arcade.enableBody(@)

      # we don't want the ground's body to be affected by gravity
      @body.allowGravity = false
      @body.immovable = true
}

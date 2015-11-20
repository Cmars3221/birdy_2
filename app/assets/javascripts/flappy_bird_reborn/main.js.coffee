# //= require_tree .

# Main Game class
#

class @Game
  GAME_WIDTH = 288
  GAME_HEIGHT = 505

  # setup the game
  @setup = ->
    # game states
    game = new Phaser.Game(GAME_WIDTH, GAME_HEIGHT, Phaser.AUTO, 'game')
    game.state.add('boot', States.Boot)
    game.state.add('preload', States.Preload)
    game.state.add('menu', States.Menu)
    game.state.add('play', States.Play)

    # start
    game.state.start('boot')


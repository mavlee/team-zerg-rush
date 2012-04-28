Game = require('./game.js').Game
Blob = require('./game.js').Blob
io = require('socket.io').listen(8080)
game = new Game()
game.start_game()

setInterval(() ->
  game.compute_state()
, Game.UPDATE_INTERVAL)

setInterval(() ->
  game.spawn_enemies()
, Game.SPAWN_INTERVAL)

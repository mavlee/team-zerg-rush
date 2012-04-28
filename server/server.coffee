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

io.sockets.on('connection', (socket) ->
  game.player_join()
  console.log('player joined')

  setInterval(() ->
    if game.is_game_over()
      socket.emit('game over')
    else
      socket.emit('game data', game.save())
  , Game.UPDATE_INTERVAL)

  socket.on('disconnect', (socket) ->
    game.player_leave()
    console.log('player left')
  )
)

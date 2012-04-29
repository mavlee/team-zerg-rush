Game = require('./game.js').Game
Blob = require('./game.js').Blob
io = require('socket.io').listen(process.env.PORT || 8080)

# assuming io is the Socket.IO server object
#io.configure(() ->
#    io.set("transports", ["xhr-polling"])
#    io.set("polling duration", 10)
#)

game = new Game()
game.start_game()

setInterval(() ->
  if game.get_player_count() > 0
    game.compute_state()
, Game.UPDATE_INTERVAL)

setInterval(() ->
  if game.get_player_count() > 0
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

  socket.on('player click', (data) ->
    console.log(data)
    game.register_click(data['x'], data['y'])
  )
)

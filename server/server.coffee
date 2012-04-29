Game = require('./game.js').Game
Blob = require('./game.js').Blob
io = require('socket.io').listen(8080)

# Socket.io configurations
# reduce logging
io.set('log level', 1)
# Methods for sending data
io.set('transports', ['websocket'
  , 'flashsocket'
  , 'htmlfile'
  , 'xhr-polling'
  , 'jsonp-polling'
])

game = new Game()
game.start_game()

setInterval(() ->
  if game.get_player_count() > 0 and game.is_game_over() == false
    game.spawn_enemies()
, Game.SPAWN_INTERVAL)

io.sockets.on('connection', (socket) ->
  game.player_join()

  # Broadcast player count to all players
  io.sockets.emit('player count', {'players': game.get_player_count()})
  socket.emit('high score', {'high score': game.get_high_score()})
  if game.is_game_over()
    socket.emit('game over')
  console.log('player joined')

  setInterval(() ->
    if game.get_player_count() > 0
      game.compute_state()
      if game.is_game_over()
        if game.is_game_on()
          game.game_on = false
          socket.emit('game data', game.save())
          socket.emit('game over')
          socket.emit('high score', {'high score': game.get_high_score()})
      else
        socket.emit('game data', game.save())
  , Game.UPDATE_INTERVAL)

  socket.on('disconnect', (socket) ->
    game.player_leave()
    io.sockets.emit('player count', {'players': game.get_player_count()})
    console.log('player left')
  )

  socket.on('player click', (data) ->
    game.register_click(data['x'], data['y'])
  )
)

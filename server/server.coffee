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
client_id_counter = 1
mice = {}

setInterval(() ->
  if game.get_player_count() > 0 and game.is_game_over() == false
    game.spawn_enemies()
, Game.SPAWN_INTERVAL)

# Send game data
setInterval(() ->
  if game.get_player_count() > 0
    game.compute_state()
    if game.is_game_over()
      io.sockets.emit('game over')
      io.sockets.emit('high score', {'high score': game.get_high_score()})
    else
      io.sockets.emit('game data', game.save())
      io.sockets.emit('mice', {'mice': mice})
, Game.UPDATE_INTERVAL)

# Uncomment if mice data being sent too frequently
#setInterval(() ->
#  if game.is_game_over() == false
#    socket.emit('mice', {'mice': mice})
#, 250)

io.sockets.on('connection', (socket) ->
  game.player_join()
  if game.get_player_count() == 1
    game.start_game()

  # Broadcast player count to all players
  io.sockets.emit('player count', {'players': game.get_player_count()})
  # Data to be sent on connetion
  socket.emit('high score', {'high score': game.get_high_score()})
  socket.emit('client id', {'id': client_id_counter})
  client_id_counter++
  if game.is_game_over()
    socket.emit('game over')
  console.log('player joined')
  
  socket.on('disconnect', (socket) ->
    game.player_leave()
    io.sockets.emit('player count', {'players': game.get_player_count()})
    mice = {}
    console.log('player left')
  )

  socket.on('player click', (data) ->
    game.register_click(data['x'], data['y'])
  )

  socket.on('mouse pos', (data) ->
    if data['id'] != 0
      mice[data['id']] = [data['x'], data['y']]
  )
)

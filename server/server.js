// Generated by CoffeeScript 1.3.1
(function() {
  var Blob, Game, client_id_counter, game, io, mice;

  Game = require('./game.js').Game;

  Blob = require('./game.js').Blob;

  io = require('socket.io').listen(8080);

  io.set('log level', 1);

  io.set('transports', ['websocket', 'flashsocket', 'htmlfile', 'xhr-polling', 'jsonp-polling']);

  game = new Game();

  game.start_game();

  client_id_counter = 1;

  mice = {};

  setInterval(function() {
    if (game.get_player_count() > 0 && game.is_game_over() === false) {
      return game.spawn_enemies();
    }
  }, Game.SPAWN_INTERVAL);

  setInterval(function() {
    if (game.get_player_count() > 0) {
      game.compute_state();
      if (game.is_game_over()) {
        io.sockets.emit('game over');
        return io.sockets.emit('high score', {
          'high score': game.get_high_score()
        });
      } else {
        io.sockets.emit('game data', game.save());
        return io.sockets.emit('mice', {
          'mice': mice
        });
      }
    }
  }, Game.UPDATE_INTERVAL);

  io.sockets.on('connection', function(socket) {
    game.player_join();
    io.sockets.emit('player count', {
      'players': game.get_player_count()
    });
    socket.emit('high score', {
      'high score': game.get_high_score()
    });
    socket.emit('client id', {
      'id': client_id_counter
    });
    client_id_counter++;
    if (game.is_game_over()) {
      socket.emit('game over');
    }
    console.log('player joined');
    socket.on('disconnect', function(socket) {
      game.player_leave();
      io.sockets.emit('player count', {
        'players': game.get_player_count()
      });
      mice = {};
      return console.log('player left');
    });
    socket.on('player click', function(data) {
      return game.register_click(data['x'], data['y']);
    });
    return socket.on('mouse pos', function(data) {
      if (data['id'] !== 0) {
        return mice[data['id']] = [data['x'], data['y']];
      }
    });
  });

}).call(this);

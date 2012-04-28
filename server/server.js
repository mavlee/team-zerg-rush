// Generated by CoffeeScript 1.3.1
(function() {
  var Blob, Game, game, io;

  Game = require('./game.js').Game;

  Blob = require('./game.js').Blob;

  io = require('socket.io').listen(8080);

  game = new Game();

  game.start_game();

  setInterval(function() {
    return game.compute_state();
  }, Game.UPDATE_INTERVAL);

  setInterval(function() {
    return game.spawn_enemies();
  }, Game.SPAWN_INTERVAL);

  io.sockets.on('connection', function(socket) {
    game.player_join();
    console.log('player joined');
    setInterval(function() {
      return socket.emit('game data', game.save());
    }, Game.UPDATE_INTERVAL);
    return socket.on('disconnect', function(socket) {
      game.player_leave();
      return console.log('player left');
    });
  });

}).call(this);

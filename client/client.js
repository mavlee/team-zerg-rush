// Generated by CoffeeScript 1.3.1
(function() {
  var BOARD_SIZE, canvas, canvasDom, client_id, colors, draw, draw_game_over, img, mice, mouse_x, mouse_y, socket;

  socket = io.connect('http://localhost:8080');

  canvasDom = document.getElementById('canvas');

  canvas = document.getElementById('canvas').getContext('2d');

  window.canvasDom = canvasDom;

  client_id = 0;

  mouse_x = 0;

  mouse_y = 0;

  mice = {};

  img = new Image();

  img.src = 'images/mouse.png';

  BOARD_SIZE = 680;

  colors = ['#000000', '#FF0000', '#FF7F00', '#FFFF00', '#00FF00', '0000FF', '#6600FF', '#8B00FF', '#330066', '#333333', '#000000'];

  socket.on('game data', function(data) {
    draw(data['blob_list']);
    document.getElementById('score').innerHTML = data['score'];
    document.getElementById('life').innerHTML = data['life'];
    return document.getElementById('life').style.color = colors[data['life']];
  });

  socket.on('game over', function() {
    draw_game_over();
    document.getElementById('life').innerHTML = 0;
    return document.getElementById('life').style.color = colors[0];
  });

  socket.on('player count', function(data) {
    return document.getElementById('player-count').innerHTML = data['players'];
  });

  socket.on('high score', function(data) {
    return document.getElementById('high-score').innerHTML = data['high score'];
  });

  socket.on('client id', function(data) {
    return client_id = data['id'];
  });

  socket.on('mice', function(data) {
    return mice = data['mice'];
  });

  draw = function(blob_list) {
    var blob, id, pos, _i, _len, _results;
    canvas.clearRect(0, 0, BOARD_SIZE, BOARD_SIZE);
    for (_i = 0, _len = blob_list.length; _i < _len; _i++) {
      blob = blob_list[_i];
      canvas.fillStyle = colors[blob.life];
      canvas.fillRect(blob.x, blob.y, blob.size, blob.size);
    }
    canvas.strokeRect(BOARD_SIZE / 2 - 25, BOARD_SIZE / 2 - 25, 50, 50);
    _results = [];
    for (id in mice) {
      pos = mice[id];
      if (parseInt(id) !== client_id) {
        _results.push(canvas.drawImage(img, 0, 0, 12, 21, pos[0], pos[1], 12, 21));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  draw_game_over = function() {
    canvas.fillStyle = "#000000";
    canvas.font = "18pt Arial";
    canvas.clearRect(0, 0, BOARD_SIZE, BOARD_SIZE);
    return canvas.fillText("GAME OVER", BOARD_SIZE / 2 - 100, BOARD_SIZE / 2 - 20);
  };

  canvasDom.onmousedown = function(e) {
    var x, y;
    x = e.offsetX;
    y = e.offsetY;
    return socket.emit('player click', {
      'x': x,
      'y': y
    });
  };

  canvasDom.onselectstart = function() {
    return false;
  };

  canvasDom.onmouseup = function(e) {
    return window.getSelection().removeAllRanges();
  };

  canvasDom.onmousemove = function(e) {
    mouse_x = e.offsetX;
    return mouse_y = e.offsetY;
  };

  setInterval(function() {
    return socket.emit('mouse pos', {
      'id': client_id,
      'x': mouse_x,
      'y': mouse_y
    });
  }, 250);

}).call(this);

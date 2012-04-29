// Generated by CoffeeScript 1.3.1
(function() {
  var Blob, Game;

  Game = (function() {

    Game.name = 'Game';

    Game.BOARD_SIZE = 680;

    Game.STARTING_BASE_LIFE = 10;

    Game.BASE_SIZE = 50;

    Game.GAME_RESTART_TIME = 5000;

    Game.SPAWN_INTERVAL = 1000;

    Game.UPDATE_INTERVAL = Math.round(1000 / 30);

    Game.prototype.blob_list = [];

    Game.prototype.base_life = 0;

    Game.prototype.player_count = 0;

    Game.prototype.enemies_killed = 0;

    Game.prototype.high_score = 0;

    Game.prototype.game_on = false;

    function Game() {
      this.blob_list = [];
      this.base_life = Game.STARTING_BASE_LIFE;
    }

    Game.prototype.start_game = function() {
      this.blob_list = [];
      this.base_life = Game.STARTING_BASE_LIFE;
      this.enemies_killed = 0;
      this.game_on = true;
      return console.log('game started');
    };

    Game.prototype.save = function() {
      var data;
      data = {
        blob_list: this.blob_list
      };
      return data;
    };

    Game.prototype.spawn_enemies = function() {
      var blob_no, c, life, pos, side, size, speed, vx, vy, x, y, _i, _ref;
      if (this.game_on !== true) {
        return;
      }
      for (blob_no = _i = 1, _ref = this.player_count * 2; 1 <= _ref ? _i <= _ref : _i >= _ref; blob_no = 1 <= _ref ? ++_i : --_i) {
        size = Math.floor(Math.random() * (50 - 10 + 1)) + 10;
        life = Math.floor(Math.random() * (Math.min(this.player_count * 2, 10))) + 1;
        speed = Math.floor(Math.random() * 40) + 1;
        side = Math.floor(Math.random() * 4) + 1;
        pos = Math.floor(Math.random() * Game.BOARD_SIZE) + 1;
        if (side === 1) {
          y = 0 - size;
          x = pos;
        } else if (side === 2) {
          y = Game.BOARD_SIZE;
          x = pos;
        } else if (side === 3) {
          y = pos;
          x = 0 - size;
        } else if (side === 4) {
          y = pos;
          x = Game.BOARD_SIZE;
        }
        c = Game.BOARD_SIZE / 2;
        vx = speed;
        vy = 1.0 * speed * (y - c) / (x - c);
        if (vy > 40) {
          vy = speed;
          vx = 1.0 * speed * (x - c) / (y - c);
        }
        if (x > c && y > c) {
          vx *= -1;
          vy *= -1;
        }
        this.blob_list.push(new Blob(size, x, y, vx, vy, life));
      }
      return console.log('enemies spawned');
    };

    Game.prototype.register_click = function(x, y) {
      var blob, _i, _len, _ref;
      _ref = this.blob_list;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        blob = _ref[_i];
        if (blob.x < x && blob.x + blob.size > x && blob.y < y && blob.y + blob.size > y) {
          if (blob.life > 0) {
            blob.life--;
            this.enemies_killed++;
            return;
          }
        }
      }
    };

    Game.prototype.compute_state = function() {
      var blob, x, _i, _len, _ref;
      if (this.game_on !== true) {
        return;
      }
      _ref = this.blob_list;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        blob = _ref[_i];
        blob.updatePosition(Game.UPDATE_INTERVAL);
        if (blob.isTouchingBase(Game.BOARD_SIZE, Game.BASE_SIZE)) {
          blob.life = 0;
          this.base_life--;
        }
      }
      this.blob_list = (function() {
        var _j, _len1, _ref1, _results;
        _ref1 = this.blob_list;
        _results = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          x = _ref1[_j];
          if (x.life > 0) {
            _results.push(x);
          }
        }
        return _results;
      }).call(this);
      if (this.base_life === 0) {
        return this.game_over();
      }
    };

    Game.prototype.game_over = function() {
      var ctx;
      console.log('game_over');
      this.blob_list = [];
      this.game_on = false;
      if (this.enemies_killed > this.high_score) {
        this.high_score = this.enemies_killed;
      }
      ctx = this;
      return setTimeout(function() {
        return ctx.start_game();
      }, Game.GAME_RESTART_TIME);
    };

    Game.prototype.is_game_over = function() {
      if (this.base_life === 0) {
        return true;
      }
      return false;
    };

    Game.prototype.get_player_count = function() {
      return this.player_count;
    };

    Game.prototype.player_join = function() {
      return this.player_count++;
    };

    Game.prototype.player_leave = function() {
      return this.player_count--;
    };

    return Game;

  })();

  Blob = (function() {

    Blob.name = 'Blob';

    Blob.prototype.size = 0;

    Blob.prototype.x = 0;

    Blob.prototype.y = 0;

    Blob.prototype.vx = 0;

    Blob.prototype.vy = 0;

    Blob.prototype.life = 0;

    function Blob(size, x, y, vx, vy, life) {
      this.size = size;
      this.x = x;
      this.y = y;
      this.vx = vx;
      this.vy = vy;
      this.life = life;
    }

    Blob.prototype.updatePosition = function(timedelta) {
      this.x += this.vx / 1000 * timedelta;
      return this.y += this.vy / 1000 * timedelta;
    };

    Blob.prototype.isTouchingBase = function(board_size, base_size) {
      var b1, b2, c, corners, _i, _len;
      b1 = board_size / 2 - base_size / 2;
      b2 = board_size / 2 + base_size / 2;
      corners = [[this.x, this.y], [this.x + this.size, this.y], [this.x, this.y + this.size], [this.x + this.size, this.y + this.size]];
      for (_i = 0, _len = corners.length; _i < _len; _i++) {
        c = corners[_i];
        if (c[0] > b1 && c[0] < b2 && c[1] > b1 && c[1] < b2) {
          return true;
        }
      }
      return false;
    };

    return Blob;

  })();

  exports.Blob = Blob;

  exports.Game = Game;

}).call(this);

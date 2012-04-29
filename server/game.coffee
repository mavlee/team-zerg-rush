class Game
  # constants
  @BOARD_SIZE: 680 # square board
  @STARTING_BASE_LIFE: 10
  @BASE_SIZE: 50
  @MAX_SPEED: 30
  @GAME_RESTART_TIME: 5000
  @SPAWN_INTERVAL: 1000
  @UPDATE_INTERVAL: Math.round(1000/30)

  # game variables
  blob_list: []
  base_life: 0
  player_count: 0
  score: 0
  high_score: 0
  game_on: false

  constructor: () ->
    this.blob_list = []
    this.base_life = Game.STARTING_BASE_LIFE

  is_game_on: () ->
    return this.game_on

  start_game: () ->
    this.blob_list = []
    this.base_life = Game.STARTING_BASE_LIFE
    this.score = 0
    this.game_on = true
    console.log('game started')

  save: () ->
    data =
      blob_list: this.blob_list
      score: this.score
    return data

  # Calibrated for SPAWN_INTERVAL
  spawn_enemies: () ->
    # Create 2 blobs for every player
    for blob_no in [1..this.player_count * 2]
      # sizes from 10 to 50px
      size = Math.floor(Math.random() * (50 - 10 + 1)) + 10
      # life is from 1 to 2 x players, to a max of 10 
      life = Math.floor(Math.random() * (Math.min(this.player_count*2, 10))) + 1
      speed = Math.floor(Math.random() * Game.MAX_SPEED) + 1
      side = Math.floor(Math.random() * 4) + 1
      pos = Math.floor(Math.random() * Game.BOARD_SIZE) + 1
      # top
      if side == 1
        y = 0 - size
        x = pos
      # bottom
      else if side == 2
        y = Game.BOARD_SIZE
        x = pos
      # left
      else if side == 3
        y = pos
        x = 0 - size
      # right
      else if side == 4
        y = pos
        x = Game.BOARD_SIZE

      c = Game.BOARD_SIZE / 2
      vx = speed
      vy = 1.0 * speed * (y - c) / (x - c)
      if vy > Game.MAX_SPEED
        vy = speed
        vx = 1.0 * speed * (x - c) / (y - c)
      if x > c and y > c
        vx *= -1
        vy *= -1

      this.blob_list.push(new Blob(size, x, y, vx, vy, life))

  register_click: (x, y) ->
    for blob in this.blob_list
      if blob.x < x and blob.x + blob.size > x and blob.y < y and blob.y + blob.size > y
        if blob.life > 0
          blob.life--
          this.score++
          return

  compute_state: () ->
    if this.is_game_over() == true
      return
    for blob in this.blob_list
      # Update positions
      blob.updatePosition(Game.UPDATE_INTERVAL)
      # Check if the base has been breached
      if blob.isTouchingBase(Game.BOARD_SIZE, Game.BASE_SIZE)
        blob.life = 0
        this.base_life--
    this.blob_list = (x for x in this.blob_list when x.life > 0)
    if this.base_life == 0
      this.game_over()

  game_over: () ->
    console.log('game_over')
    this.blob_list = []
    if this.score > this.high_score
      this.high_score = this.score
    ctx = this
    setTimeout(() ->
      ctx.start_game()
    , Game.GAME_RESTART_TIME)

  is_game_over: () ->
    if this.base_life <= 0
      return true
    return false

  get_player_count: () ->
    return this.player_count

  player_join: () ->
    this.player_count++

  player_leave: () ->
    this.player_count--

  get_score: () ->
    return this.score

  get_high_score: () ->
    return this.high_score

# Enemies - square blob
class Blob
  # Speeds are given in pixels/second
  size: 0
  x: 0
  y: 0
  vx: 0
  vy: 0
  life: 0

  constructor: (size, x, y, vx, vy, life) ->
    this.size = size
    this.x = x
    this.y = y
    this.vx = vx
    this.vy = vy
    this.life = life

  # timedelta given in ms
  updatePosition: (timedelta) ->
    this.x += this.vx / 1000 * timedelta 
    this.y += this.vy / 1000 * timedelta 

  # Checks if a blob is touching the base
  # assumes base is in the center
  isTouchingBase: (board_size, base_size) ->
    b1 = board_size / 2 - base_size / 2
    b2 = board_size / 2 + base_size / 2
    
    corners = [[this.x, this.y], [this.x + this.size, this.y], [this.x, this.y + this.size], [this.x + this.size, this.y + this.size]]

    for c in corners
      if c[0] > b1 and c[0] < b2 and c[1] > b1 and c[1] < b2
        return true

    return false

exports.Blob = Blob
exports.Game = Game

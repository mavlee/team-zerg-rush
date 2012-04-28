class Game
  # constants
  @BOARD_SIZE: 960 # square board
  @STARTING_BASE_LIFE: 10
  @BASE_SIZE: 50
  @GAME_RESTART_TIME: 5000
  @SPAWN_INTERVAL: 1000
  @UPDATE_INTERVAL: Math.round(1000/30)

  # game variables
  blob_list: []
  base_life: 0
  player_count: 0
  enemies_killed: 0
  game_on: false

  constructor: () ->
    this.blob_list = []
    this.base_life = Game.STARTING_BASE_LIFE

  start_game: () ->
    this.base_life = Game.STARTING_BASE_LIFE
    this.enemies_killed = 0
    this.game_on = true
    console.log('game started')

  save: () ->
    data =
      blob_list: this.blob_list
    return data

  # Calibrated for SPAWN_INTERVAL
  spawn_enemies: () ->
    if this.game_on != true
      return
    this.blob_list.push(new Blob(30, 480, 0, 0, 100, 2))
    this.blob_list.push(new Blob(30, 0, 480, 50, 0, 1))
    this.blob_list.push(new Blob(30, 480, 960, 0, -100, 3))
    this.blob_list.push(new Blob(30, 960, 480, -50, 0, 4))
    console.log('enemies spawned')

  compute_state: () ->
    if this.game_on != true
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
    this.game_on = false
    ctx = this
    setTimeout(() ->
      ctx.start_game()
    , Game.GAME_RESTART_TIME)

  player_join: () ->
    this.player_count++

  player_leave: () ->
    this.player_count--

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

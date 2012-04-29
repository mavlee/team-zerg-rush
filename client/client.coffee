#socket = io.connect('ec2-184-72-64-221.compute-1.amazonaws.com:8080')
socket = io.connect('http://localhost:8080')
canvasDom = document.getElementById('canvas')
canvas = document.getElementById('canvas').getContext('2d')
window.canvasDom = canvasDom
client_id = 0
mouse_x = 0
mouse_y = 0
mice = {}
img = new Image()
img.src = 'images/mouse.png'
# Keep in sync with Game.BOARD_SIZE
BOARD_SIZE = 680

colors = ['#000000', '#FF0000', '#FF7F00', '#FFFF00', '#00FF00', '0000FF', '#6600FF', '#8B00FF', '#330066', '#333333', '#000000']

socket.on('game data', (data) ->
  draw(data['blob_list'])
  document.getElementById('score').innerHTML = data['score']
  document.getElementById('life').innerHTML = data['life']
  document.getElementById('life').style.color = colors[data['life']]
)

socket.on('game over', () ->
  draw_game_over()
  document.getElementById('life').innerHTML = 0
  document.getElementById('life').style.color = colors[0]
)

socket.on('player count', (data) ->
  document.getElementById('player-count').innerHTML = data['players']
)

socket.on('high score', (data) ->
  document.getElementById('high-score').innerHTML = data['high score']
)

socket.on('client id', (data) ->
  client_id = data['id']
)

socket.on('mice', (data) ->
  mice = data['mice']
)

# This has to be kept in sync with variables in Game
draw = (blob_list) ->
  # draw blobs
  canvas.clearRect(0, 0, BOARD_SIZE, BOARD_SIZE)
  for blob in blob_list
    canvas.fillStyle = colors[blob.life]
    canvas.fillRect(blob.x, blob.y, blob.size, blob.size)

  # draw base
  canvas.strokeRect(BOARD_SIZE/2 - 25, BOARD_SIZE/2 - 25, 50, 50)

  # draw mice
  for id, pos of mice
    canvas.drawImage(img, 0, 0, 12, 21, pos[0], pos[1], 12, 21) unless parseInt(id) == client_id

draw_game_over = () ->
  canvas.fillStyle = "#000000"
  canvas.font = "18pt Arial"
  canvas.clearRect(0, 0, BOARD_SIZE, BOARD_SIZE)
  canvas.fillText("GAME OVER", BOARD_SIZE/2-100, BOARD_SIZE/2-20)

# Send click data
canvasDom.onmousedown = (e) ->
  x = e.offsetX
  y = e.offsetY
  socket.emit('player click', {'x': x, 'y': y})

# Prevent highlighting when clicking canvas
canvasDom.onselectstart = () ->
  return false

# Clear annoying selection
canvasDom.onmouseup = (e) ->
  window.getSelection().removeAllRanges()

# Record mouse positioning
canvasDom.onmousemove = (e) ->
  mouse_x = e.offsetX
  mouse_y = e.offsetY

setInterval(() ->
  socket.emit('mouse pos', {'id': client_id, 'x': mouse_x, 'y': mouse_y})
, 250)

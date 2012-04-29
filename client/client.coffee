socket = io.connect('ec2-184-72-64-221.compute-1.amazonaws.com:8080')
#socket = io.connect('http://localhost:8080')
canvasDom = document.getElementById('canvas')
canvas = document.getElementById('canvas').getContext('2d')
window.canvasDom = canvasDom
# Keep in sync with Game.BOARD_SIZE
BOARD_SIZE = 680

colors = ['', '#FF0000', '#FF7F00', '#FFFF00', '#00FF00', '0000FF', '#6600FF', '#8B00FF', '#330066', '#333333', '#000000']

socket.on('game data', (data) ->
  draw(data['blob_list'])
  document.getElementById('score').innerHTML = data['score']
  document.getElementById('life').innerHTML = data['life']
)

socket.on('game over', () ->
  draw_game_over()
)

socket.on('player count', (data) ->
  document.getElementById('player-count').innerHTML = data['players']
)

socket.on('high score', (data) ->
  document.getElementById('high-score').innerHTML = data['high score']
)

# This has to be kept in sync with variables in Game
draw = (blob_list) ->
  canvas.clearRect(0, 0, BOARD_SIZE, BOARD_SIZE)
  for blob in blob_list
    canvas.fillStyle = colors[blob.life]
    canvas.fillRect(blob.x, blob.y, blob.size, blob.size)

  canvas.strokeRect(BOARD_SIZE/2 - 25, BOARD_SIZE/2 - 25, 50, 50)

draw_game_over = () ->
  canvas.fillStyle = "#000000"
  canvas.font = "18pt Arial"
  canvas.clearRect(0, 0, BOARD_SIZE, BOARD_SIZE)
  canvas.fillText("GAME OVER", BOARD_SIZE/2-50, BOARD_SIZE/2-20)

canvasDom.onclick = (e) ->
  x = e.pageX - canvasDom.offsetLeft
  y = e.pageY - canvasDom.offsetTop
  socket.emit('player click', {'x': x, 'y': y})

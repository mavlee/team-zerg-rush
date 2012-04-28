#socket = io.connect('http://blooming-stream-4391.herokuapp.com:46612')
socket = io.connect('http://localhost:8080')
canvasDom = document.getElementById('canvas')
canvas = document.getElementById('canvas').getContext('2d')
window.canvasDom = canvasDom

colors = ['', '#FF0000', '#FF7F00', '#FFFF00', '#00FF00', '0000FF', '#6600FF', '#8B00FF', '#330066', '#333333', '#000000']

socket.on('game data', (data) ->
  draw(data['blob_list'])
)

socket.on('game over', () ->
  draw_game_over()
)

# This has to be kept in sync with variables in Game
draw = (blob_list) ->
  canvas.clearRect(0, 0, 960, 960)
  for blob in blob_list
    canvas.fillStyle = colors[blob.life]
    canvas.fillRect(blob.x, blob.y, blob.size, blob.size)

  canvas.strokeRect(960/2 - 25, 960/2 - 25, 50, 50)

draw_game_over = () ->
  canvas.fillStyle = "#000000"
  canvas.font = "18pt Arial"
  canvas.clearRect(0, 0, 960, 960)
  canvas.fillText("GAME OVER", 430, 460)

canvasDom.onclick = (e) ->
  x = e.pageX - canvasDom.offsetLeft
  y = e.pageY - canvasDom.offsetTop
  socket.emit('player click', {'x': x, 'y': y})

socket = io.connect('http://localhost:8080')
canvas = document.getElementById('canvas').getContext('2d')

colors = ['', '#FF0000', '#FF7F00', '#FFFF00', '#00FF00', '0000FF', '#6600FF', '#8B00FF', '#330066', '#333333', '#000000']

socket.on('game data', (data) ->
  draw(data['blob_list'])
)

# This has to be kept in sync with variables in Game
draw = (blob_list) ->
  canvas.clearRect(0, 0, 960, 960)
  for blob in blob_list
    canvas.fillStyle = colors[blob.life]
    canvas.fillRect(blob.x, blob.y, blob.size, blob.size)

  canvas.strokeRect(960/2 - 25, 960/2 - 25, 50, 50)

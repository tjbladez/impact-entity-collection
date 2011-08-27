express = require('express')
faye = require('faye')
server = express.createServer()
port = process.env.PORT || 2828
bayeux = new faye.NodeAdapter mount: '/faye', timeout: 45
client = bayeux.getClient()

server.configure ->
  server.set 'views', __dirname + '/views'
  server.use express.methodOverride()
  server.use express.bodyParser()
  server.use express.static(__dirname + '/public')
  server.use server.router

server.get '/', (req, res) ->
  res.render 'index.jade', locals: { title: 'Blast Mavens JS'}

rooms =
  room1: { p1: null, p2: null }
  room2: { p1: null, p2: null }
  room3: { p1: null, p2: null }
  room4: { p1: null, p2: null }

roomExtension =
  incoming: (msg, callback) ->
    if msg.channel is '/meta/disconnect'
      client.publish '/players', action: 'leave', clientId: msg.clientId
    callback msg

bayeux.addExtension roomExtension

leaveRoom = (id) ->
  for name, room of rooms
    if room.p1 and room.p1 is id
      room.p1 = null
      client.publish '/'+name, action: 'leave'
    else if room.p2 and room.p2 is id
      room.p2 = null
      client.publish '/'+name, action: 'leave'

client.subscribe '/players', (msg) ->
  name = msg.room
  id = msg.clientId
  room = rooms[name]

  switch msg.action
    when 'check'
      client.publish '/'+name, {playerCount: 0, action: 'playerCount'} unless room.p1
      client.publish '/'+name, {playerCount: 1, action: 'playerCount'} if room.p1 and not room.p2
      client.publish '/'+name, {playerCount: 2, action: 'playerCount'} if room.p1 and room.p2
    when 'join'
      if room.p1 and room.p1 is id
        client.publish '/'+name, 'connected as player1'
        return
      if room.p2 and room.p2 is id
        client.publish '/'+name, 'connected as player2'
        return
      if not room.p1
        leaveRoom id
        room.p1 = id
        client.publish '/'+name, {playerCount: 1, action: 'playerCount'}
        return
      if room.p1 and not room.p2
        leaveRoom id
        room.p2 = id
        client.publish '/game', {room: room, action: 'start'}
        return
      if room.p1 and room.p2 and room.p1 is not id and room.p2 is not id
        client.publish '/'+name, 'room is full'
        return
    when 'leave' then leaveRoom id

bayeux.attach server
server.listen port

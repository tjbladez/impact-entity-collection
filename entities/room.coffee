# An entity that represents a room for 2 people to join.
# Game starts when `you` and other player is in the same room.
# You can have as many rooms as you want. Server room extension handles
# maintaining state of rooms and in change of notifying each client/room.
# Note that some of the values are coming from my own game, obviously
# you should use your own configuration - such as animation, tile size,
# font position, number of players needed to start the game etc.
ig.module(
  'game.entities.room'
)
.requires
  'impact.entity',
  'impact.font'
)
.defines ->
  Room = ig.Entity.extend
    size: {x: 192, y: 192}
    animSheet: new ig.AnimationSheet('media/roomset.png', 192, 192)
    fontSmall: new igFont
    init: (x, y, opts) ->
      this.addAnim('idle', 1, [0])
      this.addAnim('hovered', 1, [1])
      @name         = opts.name
      @client       = opts.client
      @subscription = @client.subscribe(@name, this.roomMsgHandler, @)
      @playerCount  = 0
      @currentAnim  = @anims['idle']
      this.checkRoom()
      this.parent(x,y)
    draw: ->
      this.parent
      # always show number of players connected at the moment
      @fontSmall.draw('players:' + @playerCount, @pos.x + 48, @pos.y + 24, ig.Font.ALIGN.CENTER)
      # how instruction on hover
      if @_isHovered
        @fontBig.draw('Join ' + @name, @pos.x + 96, @pos.y + 80, ig.Font.ALIGN.CENTER)
    update: ->
      this.updateMousePosition()
      @currentAnim = if @_isHovered then @anims['hovered'] else @anims['idle']
      # if room is selected publish join request to server
      if ig.input.pressed('click') and @_isHovered
        @client.publisher('players', {room: @name, action: 'join'})
    roomMsgHandler: (msg) ->
      @playerCount = msg.playerCount if msg.action is 'playerCount'
      # when leaving make sure to update player count from server
      this.checkRoom() if msg.action is 'leave'
    checkRoom: ->
      #send a msg to server to check how many players are currently in the room
      @client.publish('players', {room: @name, action: 'check'})
    updateMousePosition: ->
      @_isHovered = this._inRange(ig.input.mouse.x, 'x') and this._inRange(ig.input.mouse.y, 'y')
    _inRange: (coord, axies) ->
      (coord >= @pos[axies]) and (coord <= (@pos[axies] + @size[axies]))

ig.module(
 'plugins.impfaye'
)
.requires(
 'impact.impact'
)
.defines ->
  ig.ImpFaye = ig.Class.extend
    init: (subscriber, opts)->
      @subscriber = subscriber
      @client     = new Faye.Client(window.location.href + 'faye')
      @client.handshake =>
        @clientId = @client.getClientId()
        opts.onHandshake.call(@subscriber) if opts.onHandshake
    publish: (channel, msg) ->
      msg.clientId = @clientId
      @client.publish('/'+channel, msg)
    subscribe: (channel, callback, scope) ->
      @client.subscribe('/'+channel, (msg)-> callback.call(scope, msg))
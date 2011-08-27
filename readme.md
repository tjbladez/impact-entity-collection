## Collection of impact related entities and servers ##

Here you will find a collection of useful entities, servers, plugins including ones for multiplayer that are constantly coming up during
conversations on `#impactjs` IRC channel.

Most of the code is written in [CoffeeScript](http://jashkenas.github.com/coffee-script/) so just compile it to js if you need javascript versions.

### Servers

* room - express js server with multiplayer room functionality built on top of faye
* uproar - express js server with broadcasting messages to clients based on params received (taken from [Uproar](https://github.com/tjbladez/uproar/blob/master/server.coffee))

### Plugins

* impfaye - [Faye](http://faye.jcoglan.com/) plugin for impact js. Allows multiplayer, broadcasting and more

### Entities

* room - Entity used in conjunction with room server. Represents a room for 2 players to join.

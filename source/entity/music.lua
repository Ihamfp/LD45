local Entity = require("entity")

return Entity {
  __name = "music",
  
  -- Options
  sources = {},
  onVolume = 1.0,
  x = 0, y = 0,
  
  -- Methods
  new = function(self, sources, onVolume, x, y)
    self.onVolume = onVolume
    self.x = x
    self.y = y
    self.isOn = false
    self.s = {}
    for i=1, #sources do
      self.s[i] = love.audio.newSource(sources[i],"stream")
      self.s[i]:setLooping(true)
      self.s[i]:setVolume(0)
    end
    Entity.new(self)
  end,
  
  -- Start the music
  start = function(self)
    for i=1, #self.s do
      self.s[i]:play()
    end
  end,
  
  -- Activate the sound
  play = function(self)
    self.isOn = true
    for i=1, #self.s do
      self.s[i]:setVolume(self.onVolume)
    end
  end,
  
  -- Stop the sound
  stop = function(self)
    self.isOn = false
    for i=1, #self.s do
      self.s[i]:setVolume(0)
    end
  end,
  
  trueStop = function(self)
    for i=1, #self.s do
      self.s[i]:stop()
    end
  end,
  
  update = function(dt)
  	print("I'M A BEEEE")
  end
}

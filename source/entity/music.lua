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
    
    self.volume = 0
    self.step = onVolume/45
    self.isGoodVolume = true
    self.isAugmenting = true
    
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
    self.isAugmenting = true
    self.isGoodVolume = false
    --for i=1, #self.s do
    --  self.s[i]:setVolume(self.onVolume)
    --end
    print("playing ".. self.__name)
  end,
  
  -- Stop the sound
  stop = function(self)
    self.isOn = false
    self.isAugmenting = false
    self.isGoodVolume = false
    --for i=1, #self.s do
    -- self.s[i]:setVolume(0)
    --end
    print("stopping ".. self.__name)
  end,
  
  trueStop = function(self)
    for i=1, #self.s do
      self.s[i]:stop()
    end
  end,
 
  -- Fade in / Fade out
  updateVolume = function(self)
    if not self.isGoodVolume then
      -- New volume
      if self.isAugmenting then
        self.volume = math.min(self.volume + self.step,1)
        if self.volume == 1 then self.isGoodVolume = true end
      else
        self.volume = math.max(self.volume - self.step,0)
        if self.volume == 0 then self.isGoodVolume = true end
      end
      
      -- Actual update
      for i=1, #self.s do
        self.s[i]:setVolume(self.volume)
      end
    end
  end,
  
  update = function(dt)
  	print("I'M A BEEEE")
  end
}

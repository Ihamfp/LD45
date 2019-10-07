local Music = require("entity.music")
local entities = require("entities")

-- ({fire,"asset/audio/6_PotOfFire.ogg"),(suffering,"asset/audio/5_SufferingPotato.ogg"})
return Music {
  __name = "potoffire",
  sources = {},
  x = 0, y = 0,
  
  new = function(self,sources,x,y)
    Music.new(self,sources,1.0,x,y)
  end,
  
  update = function(self)
    local hyke = entities.find("hyke")
    if not hyke then return end
    
    self.isOn = false
    volume = 1- 0.00001*( math.pow(hyke.x - self.x,2) + math.pow(hyke.y - self.y,2))
    for i=1, #self.s do
      self.s[i]:setVolume(volume)
    end
  end
}

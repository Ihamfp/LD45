local Music = require("entity.music")
local entities = require("entities")

-- {(correctHealth,"asset/audio/1_CorrectHealth")}
return Music {
  __name = "goodhealth",
  sources = {},
  
  new = function(self,sources)
    Music.new(self,sources,1.0,0,0)
  end,
  
  update = function(self)
    local hyke = entities.find("hyke")
    if not hyke then return end
    
    if (hyke.food <= 5 or hyke.notCold <= 5 or hyke.health <= 20) 
    then
      if self.isOn 
      then 
        self:stop() 
      end
    elseif not self.isOn 
    then 
      self:play()
    end
  end
}

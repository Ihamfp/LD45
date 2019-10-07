local Music = require("entity.music")
local entities = require("entities")

return Music {
  __name = "talkingpotato",
  sources = {},
  
  new = function(self,sources)
    Music.new(self,sources,1.0,0,0)
  end,
  
  update = function(self)
    if not (entities.find("dialog")) then
      if self.isOn 
      then 
        stop(self) 
      end
    elseif not self.isOn 
    then 
      play(self)
    end
  end
}
local Music = require("entity.music")

-- {(layer1,"asset/audio/2_RandomLayer1"),(layer2,"asset/audio/2_RandomLayer1")}
return Music {
  __name = "randomsources",
  sources = {},
  
  new = function(self,sources)
    Music.new(self,sources,1.0,0,0)
  end,
  
  update = function(self)
    if math.random() > 0.9997 then 
      if self.isOn then stop(self)
      else play(self)
      end
    end
  end
}

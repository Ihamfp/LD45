local Solidsprite = require("entity.solidsprite")
local sprite = require("entity.sprite")
local anim8 = require("anim8")
local potato1 = love.graphics.newImage("asset/sprite/potato1.png")
local potato2 = love.graphics.newImage("asset/sprite/potato2.png")
local sprites = {potato1, potato2}

return Solidsprite {
  __name = "potato",
  x=0, y=0,
  potatoVariety = 0,
  defaultText = "",

  
  new = function(self,x,y,potatoVariety,defaultText)
    self.defaultText = defaultText
    self.sprite = sprites[potatoVariety]
    self.width = 32
    self.height = 64
    Solidsprite.new(self,x,y,{width=32,height=64})
  end,
  
  draw = function(self,dx,dy)
    love.graphics.draw(self.sprite,self.x+dx,self.y+dy,0,.05,.05)
  end

}

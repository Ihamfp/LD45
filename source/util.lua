--- Various general utility functions. Extends Lume.

local util = {}

local lume = require("lume")

--- AABB collision check.
function util.aabb(x1, y1, w1, h1, x2, y2, w2, h2)
	if w1 < 0 then x1 = x1 + w1; w1 = -w1 end
	if h1 < 0 then y1 = y1 + h1; h1 = -h1 end
	if w2 < 0 then x2 = x2 + w2; w2 = -w2 end
	if h2 < 0 then y2 = y2 + h2; h2 = -h2 end
	return x1 + w1 >= x2 and x1 <= x2 + w2 and
	       y1 + h1 >= y2 and y1 <= y2 + h2
end

--- Rotate a point (x,y) arount a center (cx,cy) by an angle in radians.
-- Returns rotatedX, rotatedY (int).
function util.rotate(x, y, cx, cy, angle)
	local sin, cos = math.sin(angle), math.cos(angle)
	local tx, ty = x - cx, y - cy
	return math.floor(tx * cos - ty * sin) + cx,
	       math.floor(tx * sin + ty * cos) + cy
end

--- Have access to all lume function from this table.
lume.extend(util, lume)

return util

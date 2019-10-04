local anselme = require("anselme")("testscript.ans") -- ./run.can:3
print(require("inspect")(anselme:getAST())) -- ./run.can:5
local game = anselme:new() -- ./run.can:7
anselme:registerFunction("play audio", function(path) -- ./run.can:9
print("AAAAUUUUUUDIIIIO " .. path) -- ./run.can:10
end) -- ./run.can:10
local p -- ./run.can:13
while true do -- ./run.can:14
local e, d = game(p) -- ./run.can:15
if e == "text" then -- ./run.can:16
io["write"](d) -- ./run.can:17
elseif e == "choice" then -- ./run.can:18
for i, c in ipairs(d) do -- ./run.can:19
io["write"](tostring(i) .. ": " .. c) -- ./run.can:20
end -- ./run.can:20
local choice -- ./run.can:22
repeat -- ./run.can:23
choice = tonumber(io["read"]("*l")) -- ./run.can:24
until choice ~= nil and choice > 0 and choice <= # d -- ./run.can:25
p = choice -- ./run.can:26
elseif e == "action" then -- ./run.can:27
if d[1] == "vrai" then -- ./run.can:28
p = true -- ./run.can:29
else -- ./run.can:29
error("unknown action") -- ./run.can:31
end -- ./run.can:31
elseif e == "end" then -- ./run.can:33
break -- ./run.can:34
else -- ./run.can:34
error("unknown event (" .. tostring(e) .. ")") -- ./run.can:36
end -- ./run.can:36
end -- ./run.can:36

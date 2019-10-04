local VERSION = "0.2.0" -- ./anselme.can:112
local pvariable = "[^%{%}%§%>%<%(%)%~%+%-%*%/%%%=%!%&%|%:%^%,]*[^%{%}%§%>%<%(%)%~%+%-%*%/%%%=%!%&%|%:%^%,%s]+" -- ./anselme.can:115
local binopPriority -- ./anselme.can:118
binopPriority = { -- ./anselme.can:118
["|"] = 0, -- ./anselme.can:119
["&"] = 1, -- ./anselme.can:120
["<"] = 2, -- ./anselme.can:121
[">"] = 2, -- ./anselme.can:121
["<="] = 2, -- ./anselme.can:121
[">="] = 2, -- ./anselme.can:121
["!="] = 2, -- ./anselme.can:121
["="] = 2, -- ./anselme.can:121
["+"] = 3, -- ./anselme.can:122
["-"] = 3, -- ./anselme.can:122
["*"] = 4, -- ./anselme.can:123
["/"] = 4, -- ./anselme.can:123
["%"] = 4, -- ./anselme.can:123
["^"] = 6 -- ./anselme.can:124
} -- ./anselme.can:124
local unopPriority -- ./anselme.can:126
unopPriority = { -- ./anselme.can:126
["!"] = 5, -- ./anselme.can:127
["-"] = 5 -- ./anselme.can:127
} -- ./anselme.can:127
local anselme -- ./anselme.can:131
anselme = function(path) -- ./anselme.can:131
local f = io["open"](path, "r") -- ./anselme.can:133
if not f then -- ./anselme.can:134
error("can't open file \"" .. tostring(path) .. "\"") -- ./anselme.can:134
end -- ./anselme.can:134
local root -- ./anselme.can:137
root = { -- ./anselme.can:137
["type"] = "root", -- ./anselme.can:139
["parent"] = nil, -- parent element -- ./anselme.can:140
["children"] = {}, -- nil if the element shouldn't have children -- ./anselme.can:141
["parentParagraph"] = nil, -- closest parent paragraph -- ./anselme.can:142
["childrenParagraphs"] = {}, -- list of closest children paragraph (only defined on paragraphs and root) -- ./anselme.can:143
["condition"] = nil, -- condition expression if the line has been decorated with a condition -- ./anselme.can:144
["variables"] = {}, -- variable map -- ./anselme.can:145
["ignoreChildren"] = nil, -- true if children shouldn't be parsed -- ./anselme.can:147
["paragraph"] = nil, -- true if it is a paragraph -- ./anselme.can:148
["noInsert"] = nil, -- truf if the element shouldn't be inserted into its parent -- ./anselme.can:149
["line"] = 0 -- ./anselme.can:151
} -- ./anselme.can:151
local engineRegistry -- ./anselme.can:155
engineRegistry = { -- ./anselme.can:155
["len"] = function(str) -- ./anselme.can:156
return utf8["len"](str) -- ./anselme.can:157
end, -- ./anselme.can:157
["gsub"] = function(str, pattern, repl, n) -- ./anselme.can:159
return string["gsub"](str, pattern, repl, n) -- ./anselme.can:160
end, -- ./anselme.can:160
["random"] = function(s, e) -- ./anselme.can:162
return math["random"](s, e) -- ./anselme.can:163
end -- ./anselme.can:163
} -- ./anselme.can:163
local expression, findParagraph, findVariable, eval, formatText, run -- ./anselme.can:168
expression = function(context, str, operatingOn, minPriority) -- ./anselme.can:171
if minPriority == nil then minPriority = 0 end -- ./anselme.can:171
str = str:match("^%s*(.-)$") -- ./anselme.can:173
if not operatingOn then -- ./anselme.can:177
if str == "" then -- ./anselme.can:179
error("unexpected empty expression; at line " .. tostring(context["line"])) -- ./anselme.can:180
elseif str:match("^\"") then -- ./anselme.can:182
local string, remaining = str:match("^\"([^\"]*)\"(.*)$") -- ./anselme.can:183
return expression(context, remaining, { -- ./anselme.can:184
["type"] = "string", -- ./anselme.can:185
["value"] = string -- ./anselme.can:186
}, minPriority) -- ./anselme.can:187
elseif str:match("^%d+") then -- ./anselme.can:189
local number, remaining = str:match("^(%d+)(.*)$") -- ./anselme.can:190
return expression(context, remaining, { -- ./anselme.can:191
["type"] = "number", -- ./anselme.can:192
["value"] = tonumber(number) -- ./anselme.can:193
}, minPriority) -- ./anselme.can:194
elseif str:match("^%d*%.%d+") then -- ./anselme.can:196
local number, remaining = str:match("^(%d%.%d+)(.*)$") -- ./anselme.can:197
return expression(context, remaining, { -- ./anselme.can:198
["type"] = "number", -- ./anselme.can:199
["value"] = tonumber(number) -- ./anselme.can:200
}, minPriority) -- ./anselme.can:201
elseif str:match("^[%!%-]") then -- ./anselme.can:203
local op, remaining = str:match("^([%!%-])(.*)$") -- ./anselme.can:204
if unopPriority[op] >= minPriority then -- ./anselme.can:208
local exp, remaining, lowerPriorityOp = expression(context, remaining, nil, unopPriority[op]) -- ./anselme.can:209
local unop -- ./anselme.can:210
unop = { -- ./anselme.can:210
["type"] = "u" .. op, -- ./anselme.can:211
["expression"] = exp -- ./anselme.can:212
} -- ./anselme.can:212
if lowerPriorityOp then -- lower priority op handling -- ./anselme.can:214
return expression(context, remaining, unop, minPriority) -- ./anselme.can:215
else -- ./anselme.can:215
return unop, remaining -- ./anselme.can:217
end -- ./anselme.can:217
else -- ./anselme.can:217
return exp, str, true -- ./anselme.can:221
end -- ./anselme.can:221
elseif str:match("^%(") then -- ./anselme.can:224
local content, remaining = str:match("^(%b())(.*)$") -- ./anselme.can:225
local exp, premaining = expression(context, content:match("^%((.*)%)$"), nil) -- ./anselme.can:226
if premaining:match("[^%s]") then -- ./anselme.can:227
error("something in parantheses can't be read as an expression; at line " .. tostring(context["line"])) -- ./anselme.can:228
end -- ./anselme.can:228
return expression(context, remaining, { -- ./anselme.can:230
["type"] = "parantheses", -- ./anselme.can:231
["expression"] = exp -- ./anselme.can:232
}, minPriority) -- ./anselme.can:233
elseif str:match("^yes") then -- ./anselme.can:235
local remaining = str:match("^yes(.*)$") -- ./anselme.can:236
return expression(context, remaining, { -- ./anselme.can:237
["type"] = "number", -- ./anselme.can:238
["value"] = 1 -- ./anselme.can:239
}, minPriority) -- ./anselme.can:240
elseif str:match("^no") then -- ./anselme.can:241
local remaining = str:match("^no(.*)$") -- ./anselme.can:242
return expression(context, remaining, { -- ./anselme.can:243
["type"] = "number", -- ./anselme.can:244
["value"] = 0 -- ./anselme.can:245
}, minPriority) -- ./anselme.can:246
elseif str:match("^" .. pvariable) then -- ./anselme.can:248
local var, remaining = str:match("^(" .. pvariable .. ")(.*)$") -- ./anselme.can:249
return expression(context, remaining, { -- ./anselme.can:250
["type"] = "variable", -- ./anselme.can:251
["address"] = (function() -- ./anselme.can:252
local self = {} -- ./anselme.can:252
for s in var:gmatch("([^.]*)") do -- ./anselme.can:252
self[#self+1] = s -- ./anselme.can:252
end -- ./anselme.can:252
return self -- ./anselme.can:252
end)() -- ./anselme.can:252
}, minPriority) -- ./anselme.can:253
end -- ./anselme.can:253
else -- ./anselme.can:253
if str:match("^<=") or str:match("^>=") or str:match("^!=") or str:match("^[%&%|%+%-%*%/%%%<%>%=%^]") then -- ./anselme.can:260
local op, remaining -- ./anselme.can:261
if str:match("^[%&%|%+%-%*%/%%%<%>%=%^]") then -- ./anselme.can:262
op, remaining = str:match("^([%&%|%+%-%*%/%%%<%>%=%^])(.*)$") -- ./anselme.can:263
else -- ./anselme.can:263
op, remaining = str:match("^([<>!])=(.*)$") -- ./anselme.can:265
op = ("=") .. op -- ./anselme.can:266
end -- ./anselme.can:266
if binopPriority[op] >= minPriority then -- ./anselme.can:269
local rightVal, remaining, lowerPriorityOp = expression(context, remaining, nil, binopPriority[op]) -- ./anselme.can:270
local binop -- ./anselme.can:271
binop = { -- ./anselme.can:271
["type"] = "b" .. op, -- ./anselme.can:272
["left"] = operatingOn, -- ./anselme.can:273
["right"] = rightVal -- ./anselme.can:274
} -- ./anselme.can:274
if lowerPriorityOp then -- lower priority op handling -- ./anselme.can:276
return expression(context, remaining, binop, minPriority) -- ./anselme.can:277
else -- ./anselme.can:277
return binop, remaining -- ./anselme.can:279
end -- ./anselme.can:279
else -- ./anselme.can:279
return operatingOn, str, true -- ./anselme.can:283
end -- ./anselme.can:283
elseif str:match("^%(") then -- ./anselme.can:286
local content, remaining = str:match("^(%b())(.*)$") -- ./anselme.can:287
content = content:match("^%((.*)%)$") -- ./anselme.can:288
local args -- ./anselme.can:289
args = {} -- ./anselme.can:289
while content:match("[^%s]") do -- ./anselme.can:290
local exp -- ./anselme.can:291
exp, content = expression(context, content, nil) -- ./anselme.can:292
table["insert"](args, exp) -- ./anselme.can:293
if content:match("^%s*,%s*") then -- ./anselme.can:294
content = content:match("^%s*,%s*(.*)$") -- ./anselme.can:295
elseif content:match("[^%s]") then -- ./anselme.can:296
error("something in function parameters can't be read as an expression; at line " .. tostring(context["line"])) -- ./anselme.can:297
end -- ./anselme.can:297
end -- ./anselme.can:297
return expression(context, remaining, { -- ./anselme.can:300
["type"] = "call", -- ./anselme.can:301
["expression"] = operatingOn, -- ./anselme.can:302
["arguments"] = args -- ./anselme.can:303
}, minPriority) -- ./anselme.can:304
else -- ./anselme.can:304
return operatingOn, str -- no operator apparently -- ./anselme.can:306
end -- no operator apparently -- ./anselme.can:306
end -- no operator apparently -- ./anselme.can:306
error("the expression parser just gave up; at line " .. tostring(lineno)) -- ./anselme.can:311
end -- ./anselme.can:311
findParagraph = function(parent, address, depth) -- ./anselme.can:315
if depth == nil then depth = 1 end -- ./anselme.can:315
for _, p in ipairs(parent["childrenParagraphs"]) do -- ./anselme.can:316
if p["name"] == address[depth] then -- ./anselme.can:317
if depth < # address then -- ./anselme.can:318
return findParagraph(p, address, depth + 1) -- ./anselme.can:319
else -- ./anselme.can:319
return p -- ./anselme.can:321
end -- ./anselme.can:321
end -- ./anselme.can:321
end -- ./anselme.can:321
return nil -- ./anselme.can:325
end -- ./anselme.can:325
findVariable = function(parent, address) -- ./anselme.can:332
local par -- ./anselme.can:334
par = findParagraph((parent["type"] == "paragraph" or parent["type"] == "root") and parent or parent["parentParagraph"], address) -- ./anselme.can:334
if par then -- ./anselme.can:335
return par, par["parentParagraph"] -- ./anselme.can:336
end -- ./anselme.can:336
if # address > 1 then -- ./anselme.can:339
local pAddr = (function() -- ./anselme.can:340
local self = {} -- ./anselme.can:340
for i = 1, # address - 1, 1 do -- ./anselme.can:340
self[#self+1] = address[i] -- ./anselme.can:340
end -- ./anselme.can:340
return self -- ./anselme.can:340
end)() -- ./anselme.can:340
parent = findParagraph((parent["type"] == "paragraph" or parent["type"] == "root") and parent or parent["parentParagraph"], pAddr) -- ./anselme.can:341
if not parent then -- ./anselme.can:342
return nil -- ./anselme.can:343
end -- ./anselme.can:343
end -- ./anselme.can:343
for var, val in pairs(parent["variables"]) do -- ./anselme.can:346
if var == address[# address] then -- ./anselme.can:347
return val, parent -- ./anselme.can:348
end -- ./anselme.can:348
end -- ./anselme.can:348
return nil, parent -- ./anselme.can:351
end -- ./anselme.can:351
eval = function(context, exp) -- ./anselme.can:355
local remain = "" -- ./anselme.can:356
if type(context) == "string" and exp == nil then -- ./anselme.can:357
context, exp, remain = root, expression(context, context) -- ./anselme.can:358
end -- ./anselme.can:358
if type(exp) == "string" then -- ./anselme.can:360
exp, remain = expression(context, exp) -- ./anselme.can:361
end -- ./anselme.can:361
if remain:match("[^%s]") then -- ./anselme.can:363
error("unexpected text in expression near \"" .. tostring(remain) .. "\"; at line " .. tostring(context["line"])) -- ./anselme.can:364
end -- ./anselme.can:364
if exp["type"] == "number" then -- ./anselme.can:367
return { -- ./anselme.can:368
["type"] = "number", -- ./anselme.can:369
["value"] = exp["value"] -- ./anselme.can:370
} -- ./anselme.can:370
elseif exp["type"] == "string" then -- ./anselme.can:372
return { -- ./anselme.can:373
["type"] = "string", -- ./anselme.can:374
["value"] = exp["value"] -- ./anselme.can:375
} -- ./anselme.can:375
elseif exp["type"] == "variable" then -- ./anselme.can:377
if engineRegistry[table["concat"](exp["address"], ".")] then -- ./anselme.can:379
return { -- ./anselme.can:380
["type"] = "enginefunction", -- ./anselme.can:381
["value"] = engineRegistry[table["concat"](exp["address"], ".")] -- ./anselme.can:382
} -- ./anselme.can:382
else -- ./anselme.can:382
local v = findVariable(root, exp["address"]) -- ./anselme.can:386
if v then -- ./anselme.can:387
return { -- ./anselme.can:388
["type"] = v["type"], -- ./anselme.can:389
["value"] = v["value"] -- ./anselme.can:390
} -- ./anselme.can:390
else -- ./anselme.can:390
local parentParagraph = context -- ./anselme.can:394
while parentParagraph do -- ./anselme.can:395
local v = findVariable(parentParagraph, exp["address"]) -- ./anselme.can:396
if v then -- ./anselme.can:397
return { -- ./anselme.can:398
["type"] = v["type"], -- ./anselme.can:399
["value"] = v["value"] -- ./anselme.can:400
} -- ./anselme.can:400
end -- ./anselme.can:400
parentParagraph = parentParagraph["parentParagraph"] -- ./anselme.can:403
end -- ./anselme.can:403
error("can't find the variable (" .. tostring(table["concat"](exp["address"], ".")) .. "); at line " .. tostring(context["line"])) -- ./anselme.can:405
end -- ./anselme.can:405
end -- ./anselme.can:405
elseif exp["type"] == "parantheses" then -- ./anselme.can:408
return eval(context, exp["expression"]) -- ./anselme.can:409
elseif exp["type"] == "b+" then -- ./anselme.can:410
local left, right = eval(context, exp["left"]), eval(context, exp["right"]) -- ./anselme.can:411
if (left["type"] == "string" and (right["type"] == "string" or right["type"] == "number")) or ((left["type"] == "number" or left["type"] == "string") and right["type"] == "string") then -- ./anselme.can:413
return { -- ./anselme.can:414
["type"] = "string", -- ./anselme.can:415
["value"] = tostring(left["value"]) .. tostring(right["value"]) -- ./anselme.can:416
} -- ./anselme.can:416
elseif left["type"] == "number" and right["type"] == "number" then -- ./anselme.can:418
return { -- ./anselme.can:419
["type"] = "number", -- ./anselme.can:420
["value"] = tonumber(left["value"]) + tonumber(right["value"]) -- ./anselme.can:421
} -- ./anselme.can:421
else -- ./anselme.can:421
error("invalid value types for + operator: " .. tostring(left["type"]) .. " + " .. tostring(right["type"]) .. "; at line " .. tostring(context["line"])) -- ./anselme.can:424
end -- ./anselme.can:424
elseif exp["type"] == "b-" then -- ./anselme.can:426
local left, right = eval(context, exp["left"]), eval(context, exp["right"]) -- ./anselme.can:427
if left["type"] == "string" and right["type"] == "number" then -- ./anselme.can:428
return { -- ./anselme.can:429
["type"] = "string", -- ./anselme.can:430
["value"] = tostring(left["value"]):sub(1, utf8["offset"](left["value"], utf8["len"](left["value"]) - tonumber(right["value"]))) -- ./anselme.can:431
} -- ./anselme.can:431
elseif left["type"] == "number" and right["type"] == "string" then -- ./anselme.can:433
return { -- ./anselme.can:434
["type"] = "string", -- ./anselme.can:435
["value"] = tostring(right["value"]):sub(utf8["offset"](right["value"], tonumber(left["value"]) + 1)) -- ./anselme.can:436
} -- ./anselme.can:436
elseif left["type"] == "number" and right["type"] == "number" then -- ./anselme.can:438
return { -- ./anselme.can:439
["type"] = "number", -- ./anselme.can:440
["value"] = tonumber(left["value"]) - tonumber(right["value"]) -- ./anselme.can:441
} -- ./anselme.can:441
elseif left["type"] == "string" and right["type"] == "string" then -- ./anselme.can:443
return { -- ./anselme.can:444
["type"] = "string", -- ./anselme.can:445
["value"] = tostring(left["value"]):gsub(tostring(right["value"]), "") -- ./anselme.can:446
} -- ./anselme.can:446
else -- ./anselme.can:446
error("invalid value types for - operator: " .. tostring(left["type"]) .. " - " .. tostring(right["type"]) .. "; at line " .. tostring(context["line"])) -- ./anselme.can:449
end -- ./anselme.can:449
elseif exp["type"] == "b*" then -- ./anselme.can:451
local left, right = eval(context, exp["left"]), eval(context, exp["right"]) -- ./anselme.can:452
if left["type"] == "string" and right["type"] == "number" then -- ./anselme.can:453
return { -- ./anselme.can:454
["type"] = "string", -- ./anselme.can:455
["value"] = tostring(left["value"]):rep(tonumber(right["value"])) -- ./anselme.can:456
} -- ./anselme.can:456
elseif left["type"] == "number" and right["type"] == "string" then -- ./anselme.can:458
return { -- ./anselme.can:459
["type"] = "string", -- ./anselme.can:460
["value"] = tostring(right["value"]):rep(tonumber(left["value"])) -- ./anselme.can:461
} -- ./anselme.can:461
elseif left["type"] == "number" and right["type"] == "number" then -- ./anselme.can:463
return { -- ./anselme.can:464
["type"] = "number", -- ./anselme.can:465
["value"] = tonumber(left["value"]) * tonumber(right["value"]) -- ./anselme.can:466
} -- ./anselme.can:466
else -- ./anselme.can:466
error("invalid value types for * operator: " .. tostring(left["type"]) .. " * " .. tostring(right["type"]) .. "; at line " .. tostring(context["line"])) -- ./anselme.can:469
end -- ./anselme.can:469
elseif exp["type"] == "b/" then -- ./anselme.can:471
local left, right = eval(context, exp["left"]), eval(context, exp["right"]) -- ./anselme.can:472
if left["type"] == "string" and right["type"] == "number" then -- ./anselme.can:473
return { -- ./anselme.can:474
["type"] = "string", -- ./anselme.can:475
["value"] = tostring(left["value"]):sub(utf8["offset"](left["value"], utf8["len"](left["value"]) - tonumber(right["value"]) + 1)) -- ./anselme.can:476
} -- ./anselme.can:476
elseif left["type"] == "number" and right["type"] == "string" then -- ./anselme.can:478
return { -- ./anselme.can:479
["type"] = "string", -- ./anselme.can:480
["value"] = tostring(right["value"]):sub(1, utf8["offset"](right["value"], tonumber(left["value"]))) -- ./anselme.can:481
} -- ./anselme.can:481
elseif left["type"] == "number" and right["type"] == "number" then -- ./anselme.can:483
return { -- ./anselme.can:484
["type"] = "number", -- ./anselme.can:485
["value"] = tonumber(left["value"]) / tonumber(right["value"]) -- ./anselme.can:486
} -- ./anselme.can:486
else -- ./anselme.can:486
error("invalid value types for / operator: " .. tostring(left["type"]) .. " / " .. tostring(right["type"]) .. "; at line " .. tostring(context["line"])) -- ./anselme.can:489
end -- ./anselme.can:489
elseif exp["type"] == "b%" then -- ./anselme.can:491
local left, right = eval(context, exp["left"]), eval(context, exp["right"]) -- ./anselme.can:492
if (left["type"] == "string" and right["type"] == "number") or (left["type"] == "number" and right["type"] == "string") then -- ./anselme.can:493
return { -- ./anselme.can:494
["type"] = "number", -- ./anselme.can:495
["value"] = tostring(left["value"]):find(tostring(right["value"])) or 0 -- ./anselme.can:496
} -- ./anselme.can:496
elseif left["type"] == "number" and right["type"] == "number" then -- ./anselme.can:498
return { -- ./anselme.can:499
["type"] = "number", -- ./anselme.can:500
["value"] = tonumber(left["value"]) % tonumber(right["value"]) -- ./anselme.can:501
} -- ./anselme.can:501
else -- ./anselme.can:501
error("invalid value types for % operator: " .. tostring(left["type"]) .. " % " .. tostring(right["type"]) .. "; at line " .. tostring(context["line"])) -- ./anselme.can:504
end -- ./anselme.can:504
elseif exp["type"] == "b^" then -- ./anselme.can:506
local left, right = eval(context, exp["left"]), eval(context, exp["right"]) -- ./anselme.can:507
if left["type"] == "string" then -- ./anselme.can:508
local s = tostring(left["value"]) -- ./anselme.can:509
if right["value"] == 0 then -- ./anselme.can:510
s = s:lower() -- ./anselme.can:511
else -- ./anselme.can:511
s = s:upper() -- ./anselme.can:513
end -- ./anselme.can:513
return { -- ./anselme.can:515
["type"] = "string", -- ./anselme.can:516
["value"] = s -- ./anselme.can:517
} -- ./anselme.can:517
elseif left["type"] == "number" and right["type"] == "number" then -- ./anselme.can:519
return { -- ./anselme.can:520
["type"] = "number", -- ./anselme.can:521
["value"] = tonumber(left["value"]) ^ tonumber(right["value"]) -- ./anselme.can:522
} -- ./anselme.can:522
else -- ./anselme.can:522
error("invalid value types for ^ operator: " .. tostring(left["type"]) .. " ^ " .. tostring(right["type"]) .. "; at line " .. tostring(context["line"])) -- ./anselme.can:525
end -- ./anselme.can:525
elseif exp["type"] == "b>" then -- ./anselme.can:527
local left, right = eval(context, exp["left"]), eval(context, exp["right"]) -- ./anselme.can:528
if (left["type"] == "number" or left["type"] == "string") and (right["type"] == "number" or right["type"] == "string") then -- ./anselme.can:529
local v = left["value"] > right["value"] -- ./anselme.can:530
return { -- ./anselme.can:531
["type"] = "number", -- ./anselme.can:532
["value"] = v and 1 or 0 -- ./anselme.can:533
} -- ./anselme.can:533
elseif left["type"] == "paragraph" and (right["type"] == "number" or right["type"] == "string") then -- ./anselme.can:535
local ok = true -- ./anselme.can:536
for n, var in pairs(left["value"]["variables"]) do -- ./anselme.can:537
if not var["default"] then -- ./anselme.can:538
local r -- ./anselme.can:539
r = eval(context, { -- ./anselme.can:539
["type"] = "b>", -- ./anselme.can:540
["left"] = var, -- ./anselme.can:541
["right"] = right -- ./anselme.can:542
}) -- ./anselme.can:542
if r["value"] == 0 then -- ./anselme.can:544
ok = false -- ./anselme.can:545
break -- ./anselme.can:546
end -- ./anselme.can:546
end -- ./anselme.can:546
end -- ./anselme.can:546
return { -- ./anselme.can:550
["type"] = "number", -- ./anselme.can:551
["value"] = ok and 1 or 0 -- ./anselme.can:552
} -- ./anselme.can:552
else -- ./anselme.can:552
error("invalid value types for > operator: " .. tostring(left["type"]) .. " > " .. tostring(right["type"]) .. "; at line " .. tostring(context["line"])) -- ./anselme.can:555
end -- ./anselme.can:555
elseif exp["type"] == "b<" then -- ./anselme.can:557
local left, right = eval(context, exp["left"]), eval(context, exp["right"]) -- ./anselme.can:558
if (left["type"] == "number" or left["type"] == "string") and (right["type"] == "number" or right["type"] == "string") then -- ./anselme.can:559
local v = left["value"] < right["value"] -- ./anselme.can:560
return { -- ./anselme.can:561
["type"] = "number", -- ./anselme.can:562
["value"] = v and 1 or 0 -- ./anselme.can:563
} -- ./anselme.can:563
elseif left["type"] == "paragraph" and (right["type"] == "number" or right["type"] == "string") then -- ./anselme.can:565
local ok = true -- ./anselme.can:566
for n, var in pairs(left["value"]["variables"]) do -- ./anselme.can:567
if not var["default"] then -- ./anselme.can:568
local r -- ./anselme.can:569
r = eval(context, { -- ./anselme.can:569
["type"] = "b<", -- ./anselme.can:570
["left"] = var, -- ./anselme.can:571
["right"] = right -- ./anselme.can:572
}) -- ./anselme.can:572
if r["value"] == 0 then -- ./anselme.can:574
ok = false -- ./anselme.can:575
break -- ./anselme.can:576
end -- ./anselme.can:576
end -- ./anselme.can:576
end -- ./anselme.can:576
return { -- ./anselme.can:580
["type"] = "number", -- ./anselme.can:581
["value"] = ok and 1 or 0 -- ./anselme.can:582
} -- ./anselme.can:582
else -- ./anselme.can:582
error("invalid value types for > operator: " .. tostring(left["type"]) .. " > " .. tostring(right["type"]) .. "; at line " .. tostring(context["line"])) -- ./anselme.can:585
end -- ./anselme.can:585
elseif exp["type"] == "b>=" then -- ./anselme.can:587
local left, right = eval(context, exp["left"]), eval(context, exp["right"]) -- ./anselme.can:588
if (left["type"] == "number" or left["type"] == "string") and (right["type"] == "number" or right["type"] == "string") then -- ./anselme.can:589
local v = left["value"] >= right["value"] -- ./anselme.can:590
return { -- ./anselme.can:591
["type"] = "number", -- ./anselme.can:592
["value"] = v and 1 or 0 -- ./anselme.can:593
} -- ./anselme.can:593
elseif left["type"] == "paragraph" and (right["type"] == "number" or right["type"] == "string") then -- ./anselme.can:595
local ok = true -- ./anselme.can:596
for n, var in pairs(left["value"]["variables"]) do -- ./anselme.can:597
if not var["default"] then -- ./anselme.can:598
local r -- ./anselme.can:599
r = eval(context, { -- ./anselme.can:599
["type"] = "b>=", -- ./anselme.can:600
["left"] = var, -- ./anselme.can:601
["right"] = right -- ./anselme.can:602
}) -- ./anselme.can:602
if r["value"] == 0 then -- ./anselme.can:604
ok = false -- ./anselme.can:605
break -- ./anselme.can:606
end -- ./anselme.can:606
end -- ./anselme.can:606
end -- ./anselme.can:606
return { -- ./anselme.can:610
["type"] = "number", -- ./anselme.can:611
["value"] = ok and 1 or 0 -- ./anselme.can:612
} -- ./anselme.can:612
else -- ./anselme.can:612
error("invalid value types for > operator: " .. tostring(left["type"]) .. " > " .. tostring(right["type"]) .. "; at line " .. tostring(context["line"])) -- ./anselme.can:615
end -- ./anselme.can:615
elseif exp["type"] == "b<=" then -- ./anselme.can:617
local left, right = eval(context, exp["left"]), eval(context, exp["right"]) -- ./anselme.can:618
if (left["type"] == "number" or left["type"] == "string") and (right["type"] == "number" or right["type"] == "string") then -- ./anselme.can:619
local v = left["value"] <= right["value"] -- ./anselme.can:620
return { -- ./anselme.can:621
["type"] = "number", -- ./anselme.can:622
["value"] = v and 1 or 0 -- ./anselme.can:623
} -- ./anselme.can:623
elseif left["type"] == "paragraph" and (right["type"] == "number" or right["type"] == "string") then -- ./anselme.can:625
local ok = true -- ./anselme.can:626
for n, var in pairs(left["value"]["variables"]) do -- ./anselme.can:627
if not var["default"] then -- ./anselme.can:628
local r -- ./anselme.can:629
r = eval(context, { -- ./anselme.can:629
["type"] = "b<=", -- ./anselme.can:630
["left"] = var, -- ./anselme.can:631
["right"] = right -- ./anselme.can:632
}) -- ./anselme.can:632
if r["value"] == 0 then -- ./anselme.can:634
ok = false -- ./anselme.can:635
break -- ./anselme.can:636
end -- ./anselme.can:636
end -- ./anselme.can:636
end -- ./anselme.can:636
return { -- ./anselme.can:640
["type"] = "number", -- ./anselme.can:641
["value"] = ok and 1 or 0 -- ./anselme.can:642
} -- ./anselme.can:642
else -- ./anselme.can:642
error("invalid value types for > operator: " .. tostring(left["type"]) .. " > " .. tostring(right["type"]) .. "; at line " .. tostring(context["line"])) -- ./anselme.can:645
end -- ./anselme.can:645
elseif exp["type"] == "b=" then -- ./anselme.can:647
local left, right = eval(context, exp["left"]), eval(context, exp["right"]) -- ./anselme.can:648
local v = left["value"] == right["value"] -- ./anselme.can:649
return { -- ./anselme.can:650
["type"] = "number", -- ./anselme.can:651
["value"] = v and 1 or 0 -- ./anselme.can:652
} -- ./anselme.can:652
elseif exp["type"] == "b!=" then -- ./anselme.can:654
local left, right = eval(context, exp["left"]), eval(context, exp["right"]) -- ./anselme.can:655
local v = left["value"] ~= right["value"] -- ./anselme.can:656
return { -- ./anselme.can:657
["type"] = "number", -- ./anselme.can:658
["value"] = v and 1 or 0 -- ./anselme.can:659
} -- ./anselme.can:659
elseif exp["type"] == "b&" then -- ./anselme.can:661
local left, right = eval(context, exp["left"]), eval(context, exp["right"]) -- ./anselme.can:662
if left["value"] ~= 0 then -- ./anselme.can:663
return right -- ./anselme.can:664
else -- ./anselme.can:664
return left -- ./anselme.can:666
end -- ./anselme.can:666
elseif exp["type"] == "b|" then -- ./anselme.can:668
local left, right = eval(context, exp["left"]), eval(context, exp["right"]) -- ./anselme.can:669
if left["value"] ~= 0 then -- ./anselme.can:670
return left -- ./anselme.can:671
else -- ./anselme.can:671
return right -- ./anselme.can:673
end -- ./anselme.can:673
elseif exp["type"] == "u!" then -- ./anselme.can:675
local value = eval(context, exp["expression"]) -- ./anselme.can:676
return { -- ./anselme.can:677
["type"] = "number", -- ./anselme.can:678
["value"] = value["value"] == 0 and 1 or 0 -- ./anselme.can:679
} -- ./anselme.can:679
elseif exp["type"] == "u-" then -- ./anselme.can:681
local value = eval(context, exp["expression"]) -- ./anselme.can:682
if value["type"] == "number" then -- ./anselme.can:683
return { -- ./anselme.can:684
["type"] = "number", -- ./anselme.can:685
["value"] = - tonumber(value["value"]) -- ./anselme.can:686
} -- ./anselme.can:686
elseif value["type"] == "string" then -- ./anselme.can:688
return { -- ./anselme.can:689
["type"] = "string", -- ./anselme.can:690
["value"] = value["value"]:reverse() -- ./anselme.can:691
} -- ./anselme.can:691
else -- ./anselme.can:691
error("invalid value types for - operator: " .. tostring(value["type"]) .. "; at line " .. tostring(context["line"])) -- ./anselme.can:694
end -- ./anselme.can:694
elseif exp["type"] == "call" then -- ./anselme.can:696
local fn = eval(context, exp["expression"]) -- ./anselme.can:698
if fn["type"] == "paragraph" then -- ./anselme.can:699
local p = fn["value"] -- ./anselme.can:701
if # exp["arguments"] ~= # p["parameters"] then -- ./anselme.can:702
error("function (" .. tostring(p["name"]) .. "; at line " .. tostring(p["line"]) .. ") expected " .. tostring(# p["parameters"]) .. " parameters but received " .. tostring(# exp["arguments"]) .. "; at line " .. tostring(context["line"])) -- ./anselme.can:703
end -- ./anselme.can:703
for i, arg in ipairs(exp["arguments"]) do -- ./anselme.can:705
p["variables"][p["parameters"][i]] = eval(context, arg) -- ./anselme.can:706
end -- ./anselme.can:706
p["variables"]["return"] = eval("0") -- ./anselme.can:709
p["variables"]["return"]["default"] = true -- ./anselme.can:710
run(p["children"]) -- ./anselme.can:711
p["variables"]["used"]["value"] = p["variables"]["used"]["value"] + (1) -- ./anselme.can:712
return { -- ./anselme.can:713
["type"] = p["variables"]["return"]["type"], -- ./anselme.can:714
["value"] = p["variables"]["return"]["value"] -- ./anselme.can:715
} -- ./anselme.can:715
elseif fn["type"] == "enginefunction" then -- ./anselme.can:717
local args -- ./anselme.can:718
args = {} -- ./anselme.can:718
for i, arg in ipairs(exp["arguments"]) do -- ./anselme.can:719
local val = eval(context, arg) -- ./anselme.can:720
table["insert"](args, val["value"]) -- ./anselme.can:721
end -- ./anselme.can:721
local ret = fn["value"](unpack(args)) -- ./anselme.can:723
if ret == nil or ret == false then -- ./anselme.can:724
return eval("no") -- ./anselme.can:725
elseif ret == true then -- ./anselme.can:726
return eval("yes") -- ./anselme.can:727
elseif type(ret) == "number" then -- ./anselme.can:728
return { -- ./anselme.can:729
["type"] = "number", -- ./anselme.can:730
["value"] = ret -- ./anselme.can:731
} -- ./anselme.can:731
elseif type(ret) == "string" then -- ./anselme.can:733
return { -- ./anselme.can:734
["type"] = "number", -- ./anselme.can:735
["value"] = ret -- ./anselme.can:736
} -- ./anselme.can:736
elseif type(ret) == "function" then -- ./anselme.can:738
return { -- ./anselme.can:739
["type"] = "enginefunction", -- ./anselme.can:740
["value"] = ret -- ./anselme.can:741
} -- ./anselme.can:741
else -- ./anselme.can:741
error("invalid return type (" .. type(ret) .. ") for engine function in expression; at line " .. tostring(context["line"])) -- ./anselme.can:744
end -- ./anselme.can:744
else -- ./anselme.can:744
error("tried to call a " .. tostring(fn["type"]) .. " variable in an expression; at line " .. tostring(context["line"])) -- ./anselme.can:747
end -- ./anselme.can:747
else -- ./anselme.can:747
error("unkown expression (" .. tostring(exp["type"]) .. ") to evaluate; at line " .. tostring(context["line"])) -- ./anselme.can:750
end -- ./anselme.can:750
end -- ./anselme.can:750
formatText = function(context, text) -- ./anselme.can:755
local r -- ./anselme.can:756
r = text:gsub("{([^}]*)}", function(exp) -- ./anselme.can:756
local val = eval(context, exp) -- ./anselme.can:757
if val["type"] == "paragraph" then -- run paragraph/function -- ./anselme.can:758
local p = val["value"] -- ./anselme.can:759
if # p["parameters"] > 0 then -- ./anselme.can:760
error("paragraph returned by the expression expected " .. tostring(# p["parameters"]) .. " parameters but received none; at line " .. tostring(context["line"])) -- ./anselme.can:761
end -- ./anselme.can:761
p["variables"]["return"] = eval("0") -- ./anselme.can:763
p["variables"]["return"]["default"] = true -- ./anselme.can:764
run(p["children"]) -- ./anselme.can:765
p["variables"]["used"]["value"] = p["variables"]["used"]["value"] + (1) -- ./anselme.can:766
val = p["variables"]["return"] -- ./anselme.can:767
end -- ./anselme.can:767
return tostring(val["value"]) -- ./anselme.can:769
end) -- ./anselme.can:769
if r:match("\\$") then -- ./anselme.can:771
r = r:gsub("\\$", "") -- ./anselme.can:772
else -- ./anselme.can:772
r = r .. "\
" -- ./anselme.can:774
end -- ./anselme.can:774
return r -- ./anselme.can:776
end -- ./anselme.can:776
run = function(lines) -- ./anselme.can:780
for _, line in ipairs(lines) do -- ./anselme.can:781
repeat -- ./anselme.can:781
if line["condition"] then -- ./anselme.can:783
if eval(line, line["condition"])["value"] == 0 then -- ./anselme.can:784
break -- ./anselme.can:785
end -- ./anselme.can:785
end -- ./anselme.can:785
if line["type"] == "comment" then -- ./anselme.can:789
 -- ./anselme.can:791
elseif line["type"] == "paragraph" then -- ./anselme.can:791
line["variables"]["seen"]["value"] = line["variables"]["seen"]["value"] + (1) -- ./anselme.can:792
elseif line["type"] == "choices" then -- ./anselme.can:793
local l -- ./anselme.can:794
l = {} -- ./anselme.can:794
for i, c in ipairs(line["children"]) do -- ./anselme.can:795
if c["type"] ~= "choice" then -- ./anselme.can:796
error("expected a choice, got a " .. tostring(c["type"]) .. "; somewhere in Anselme's internals, triggered by line " .. tostring(line["line"])) -- ./anselme.can:796
end -- ./anselme.can:796
table["insert"](l, formatText(c, c["text"])) -- ./anselme.can:797
c["variables"]["seen"]["value"] = c["variables"]["seen"]["value"] + (1) -- ./anselme.can:798
end -- ./anselme.can:798
local choice = coroutine["yield"]("choice", l) -- ./anselme.can:800
if not choice then -- ./anselme.can:801
error("no choice has been made by the engine, I don't know what to doooo") -- ./anselme.can:802
end -- ./anselme.can:802
local c = line["children"][choice] -- ./anselme.can:804
run(c["children"]) -- ./anselme.can:805
c["variables"]["used"]["value"] = c["variables"]["used"]["value"] + (1) -- ./anselme.can:806
elseif line["type"] == "definition" then -- ./anselme.can:807
 -- ./anselme.can:809
elseif line["type"] == "assignement" then -- ./anselme.can:809
local exp = eval(line, line["expression"]) -- ./anselme.can:811
if line["operator"] ~= "=" then -- ./anselme.can:812
exp = eval(line, { -- ./anselme.can:813
["type"] = "b" .. line["operator"], -- ./anselme.can:814
["left"] = { -- ./anselme.can:815
["type"] = "variable", -- ./anselme.can:816
["address"] = line["address"] -- ./anselme.can:817
}, -- ./anselme.can:817
["right"] = exp -- ./anselme.can:819
}) -- ./anselme.can:819
end -- ./anselme.can:819
local v, par = findVariable(root, line["address"]) -- ./anselme.can:823
if not v then -- ./anselme.can:824
local found = false -- ./anselme.can:826
local parentParagraph = line["parentParagraph"] -- skip current line (no variables) -- ./anselme.can:827
while parentParagraph do -- ./anselme.can:828
v, par = findVariable(parentParagraph, line["address"]) -- ./anselme.can:829
if v then -- ./anselme.can:830
found = true -- ./anselme.can:831
break -- ./anselme.can:832
end -- ./anselme.can:832
parentParagraph = parentParagraph["parentParagraph"] -- ./anselme.can:834
end -- ./anselme.can:834
if not found then -- ./anselme.can:836
error("can't find the variable (" .. tostring(table["concat"](line["address"], ".")) .. "); at line " .. tostring(line["line"])) -- ./anselme.can:837
end -- ./anselme.can:837
end -- ./anselme.can:837
if par["variables"][line["address"][# line["address"]]] then -- ./anselme.can:841
par["variables"][line["address"][# line["address"]]] = { -- ./anselme.can:842
["type"] = exp["type"], -- ./anselme.can:843
["value"] = exp["value"] -- ./anselme.can:844
} -- ./anselme.can:844
else -- ./anselme.can:844
error("found the variable (" .. tostring(table["concat"](line["address"], ".")) .. ") to assign, but it's read only; at line " .. tostring(line["line"])) -- ./anselme.can:847
end -- ./anselme.can:847
elseif line["type"] == "redirections" then -- ./anselme.can:849
for i, c in ipairs(line["children"]) do -- ./anselme.can:850
if i == 1 and c["type"] ~= "redirection" then -- ./anselme.can:851
error("expected a redirection, got a " .. tostring(c["type"]) .. "; somewhere in Anselme's internals, triggered by line " .. tostring(line["line"])) -- ./anselme.can:852
end -- ./anselme.can:852
if i > 1 and c["type"] ~= "elseredirection" then -- ./anselme.can:854
error("expected an elseredirection, got a " .. tostring(c["type"]) .. "; somewhere in Anselme's internals, triggered by line " .. tostring(line["line"])) -- ./anselme.can:855
end -- ./anselme.can:855
local val = eval(c, c["expression"]) -- ./anselme.can:857
if val["type"] == "paragraph" then -- run paragraph/function -- ./anselme.can:858
local p = val["value"] -- ./anselme.can:859
if # p["parameters"] > 0 then -- ./anselme.can:860
error("paragraph returned by the expression expected " .. tostring(# p["parameters"]) .. " parameters but received none; at line " .. tostring(context["line"])) -- ./anselme.can:861
end -- ./anselme.can:861
p["variables"]["return"] = eval("0") -- ./anselme.can:863
p["variables"]["return"]["default"] = true -- ./anselme.can:864
run(p["children"]) -- ./anselme.can:865
p["variables"]["used"]["value"] = p["variables"]["used"]["value"] + (1) -- ./anselme.can:866
val = p["variables"]["return"] -- ./anselme.can:867
end -- ./anselme.can:867
c["variables"]["seen"]["value"] = c["variables"]["seen"]["value"] + (1) -- ./anselme.can:869
if val["value"] ~= 0 then -- ./anselme.can:870
run(c["children"]) -- ./anselme.can:871
c["variables"]["used"]["value"] = c["variables"]["used"]["value"] + (1) -- ./anselme.can:872
break -- ./anselme.can:873
end -- ./anselme.can:873
end -- ./anselme.can:873
elseif line["type"] == "text" then -- ./anselme.can:876
coroutine["yield"]("text", formatText(line, line["text"])) -- ./anselme.can:877
line["variables"]["seen"]["value"] = line["variables"]["seen"]["value"] + (1) -- ./anselme.can:878
else -- ./anselme.can:878
error("element unkown to the runtime (" .. tostring(line["type"]) .. "); at line " .. tostring(line["line"])) -- ./anselme.can:880
end -- ./anselme.can:880
until true -- ./anselme.can:880
end -- ./anselme.can:880
end -- ./anselme.can:880
local parent = root -- current parent element -- ./anselme.can:886
local parentParagraph = root -- closest parent paragraph -- ./anselme.can:887
local lastParsed = nil -- last parsed element -- ./anselme.can:888
local indent = 0 -- current indentation level -- ./anselme.can:889
local lineno = 0 -- line number -- ./anselme.can:890
for l in f:lines() do -- ./anselme.can:891
repeat -- ./anselme.can:891
lineno = lineno + (1) -- ./anselme.can:892
local tabs, line = l:match("^(\9*)(.*)$") -- ./anselme.can:895
if line == "" then -- ./anselme.can:896
break -- ./anselme.can:896
end -- ./anselme.can:896
local level = # tabs -- ./anselme.can:897
if level == indent + 1 and not parent["ignoreChildren"] then -- ./anselme.can:900
indent = indent + (1) -- ./anselme.can:901
parent = lastParsed -- ./anselme.can:902
if parent["paragraph"] then -- ./anselme.can:903
parentParagraph = parent -- ./anselme.can:904
end -- ./anselme.can:904
if not parent["children"] then -- ./anselme.can:906
error("a line doesn't want children but was given some; at line " .. tostring(lineno)) -- ./anselme.can:907
end -- ./anselme.can:907
elseif level < indent then -- ./anselme.can:910
while level < indent do -- ./anselme.can:911
indent = indent - (1) -- ./anselme.can:912
if parent["paragraph"] then -- ./anselme.can:913
parentParagraph = parentParagraph["parent"] -- ./anselme.can:914
end -- ./anselme.can:914
parent = parent["parent"] -- ./anselme.can:916
end -- ./anselme.can:916
elseif level ~= indent and not parent["ignoreChildren"] then -- ./anselme.can:919
error("invalid indentation; at line " .. tostring(lineno)) -- ./anselme.can:920
end -- ./anselme.can:920
if not parent["ignoreChildren"] then -- ./anselme.can:924
local parsed -- element -- ./anselme.can:925
parsed = { -- element -- ./anselme.can:925
["type"] = "unknown", -- ./anselme.can:926
["parent"] = parent, -- ./anselme.can:927
["children"] = nil, -- ./anselme.can:928
["parentParagraph"] = parentParagraph, -- ./anselme.can:929
["childrenParagraphs"] = nil, -- ./anselme.can:930
["condition"] = nil, -- ./anselme.can:931
["variables"] = {}, -- ./anselme.can:932
["ignoreChildren"] = nil, -- ./anselme.can:933
["paragraph"] = nil, -- ./anselme.can:934
["line"] = lineno -- ./anselme.can:935
} -- ./anselme.can:935
if line:match("^%s*[^%~].*%~[^%~]+$") then -- ./anselme.can:938
local l, c = line:match("^(%s*[^%~].*)%~([^%~]+)$") -- ./anselme.can:939
local exp, rem = expression(parsed, c) -- ./anselme.can:940
if rem:match("[^%s]") then -- ./anselme.can:941
error("invalid condition decorator expression near \"" .. tostring(rem) .. "\"; at line " .. tostring(lineno)) -- ./anselme.can:942
else -- ./anselme.can:942
line = l -- ./anselme.can:944
parsed["condition"] = exp -- ./anselme.can:945
end -- ./anselme.can:945
end -- ./anselme.can:945
if line:match("^%(") then -- ./anselme.can:949
parsed["type"] = "comment" -- ./anselme.can:950
parsed["children"] = {} -- ./anselme.can:951
parsed["ignoreChildren"] = true -- ./anselme.can:952
elseif line:match("^§") then -- ./anselme.can:954
parsed["type"] = "paragraph" -- ./anselme.can:955
parsed["name"] = line:match("^§%s*(.-)%s*$") -- ./anselme.can:956
parsed["parameters"] = {} -- ./anselme.can:957
if parsed["name"]:match("^.-%s*%(.-%)%s*$") then -- ./anselme.can:959
local name, content = parsed["name"]:match("^(.-)%s*%((.-)%)%s*$") -- ./anselme.can:960
parsed["name"] = name -- ./anselme.can:961
for par in content:gmatch("[^,]*") do -- ./anselme.can:962
local var = par:match("^%s*(.-)%s*$") -- ./anselme.can:963
table["insert"](parsed["parameters"], var) -- ./anselme.can:964
parsed["variables"][var] = eval("0") -- ./anselme.can:965
end -- ./anselme.can:965
end -- ./anselme.can:965
parsed["value"] = parsed -- paragraphs are variables themselves -- ./anselme.can:968
parsed["paragraph"] = true -- ./anselme.can:969
parsed["children"] = {} -- ./anselme.can:970
parsed["variables"]["seen"] = eval("0") -- ./anselme.can:971
parsed["variables"]["seen"]["default"] = true -- ./anselme.can:972
parsed["variables"]["used"] = eval("0") -- ./anselme.can:973
parsed["variables"]["used"]["default"] = true -- ./anselme.can:974
parsed["variables"]["return"] = eval("0") -- ./anselme.can:975
parsed["variables"]["return"]["default"] = true -- ./anselme.can:976
elseif line:match("^>") then -- ./anselme.can:978
parsed["type"] = "choice" -- ./anselme.can:979
parsed["text"] = line:match("^>%s*(.-)%s*$") -- ./anselme.can:980
parsed["children"] = {} -- ./anselme.can:981
parsed["variables"]["seen"] = eval("0") -- ./anselme.can:982
parsed["variables"]["seen"]["default"] = true -- ./anselme.can:983
parsed["variables"]["used"] = eval("0") -- ./anselme.can:984
parsed["variables"]["used"]["default"] = true -- ./anselme.can:985
if parent["children"][# parent["children"]] == nil or parent["children"][# parent["children"]]["type"] ~= "choices" then -- ./anselme.can:987
table["insert"](parent["children"], { -- ./anselme.can:988
["type"] = "choices", -- ./anselme.can:989
["parent"] = parent, -- ./anselme.can:990
["children"] = {}, -- ./anselme.can:991
["parentParagraph"] = parentParagraph, -- ./anselme.can:992
["childrenParagraphs"] = nil, -- ./anselme.can:993
["condition"] = nil, -- ./anselme.can:994
["variables"] = {}, -- ./anselme.can:995
["ignoreChildren"] = nil, -- ./anselme.can:996
["paragraph"] = nil, -- ./anselme.can:997
["noInsert"] = nil, -- ./anselme.can:998
["line"] = lineno -- ./anselme.can:999
}) -- ./anselme.can:999
end -- ./anselme.can:999
table["insert"](parent["children"][# parent["children"]]["children"], parsed) -- ./anselme.can:1002
parsed["noInsert"] = true -- ./anselme.can:1003
elseif line:match("^:") then -- ./anselme.can:1005
parsed["type"] = "definition" -- ./anselme.can:1006
parsed["expression"], parsed["address"] = expression(parsed, line:match("^:%s*(.-)%s*$")) -- ./anselme.can:1007
parsed["address"] = parsed["address"]:match("^%s*(.-)$") -- ./anselme.can:1008
if not parsed["address"]:match("^" .. pvariable .. "$") then -- ./anselme.can:1009
error("unreasonably invalid variable name (" .. tostring(parsed["address"]) .. "); at line " .. tostring(lineno)) -- ./anselme.can:1010
end -- ./anselme.can:1010
parsed["address"] = (function() -- ./anselme.can:1012
local self = {} -- ./anselme.can:1012
for s in parsed["address"]:gmatch("([^.]*)") do -- ./anselme.can:1012
self[#self+1] = s -- ./anselme.can:1012
end -- ./anselme.can:1012
return self -- ./anselme.can:1012
end)() -- ./anselme.can:1012
local var, par = findVariable(parsed["parentParagraph"], parsed["address"]) -- ./anselme.can:1014
if not var then -- ./anselme.can:1015
if par then -- ./anselme.can:1016
par["variables"][parsed["address"][# parsed["address"]]] = eval(parsed, parsed["expression"]) -- ./anselme.can:1017
else -- ./anselme.can:1017
error("can't find variable (" .. table["concat"](parsed["address"], ".") .. "), some paragraphs in the address don't exist (why are you specifying paragraphs in a definition anyway? that's not very readable); at line " .. tostring(parsed["line"])) -- ./anselme.can:1019
end -- ./anselme.can:1019
else -- ./anselme.can:1019
error("trying to define a variable (" .. table["concat"](parsed["address"], ".") .. ") which is already defined; at line " .. tostring(parsed["line"])) -- ./anselme.can:1022
end -- ./anselme.can:1022
elseif line:match("^[%=%+%-%*%/%%%!%^%&%|]") then -- ./anselme.can:1025
parsed["type"] = "assignement" -- ./anselme.can:1026
parsed["operator"] = line:match("^([%=%+%-%*%/%%%!%^%&%|])") -- ./anselme.can:1027
parsed["expression"], parsed["address"] = expression(parsed, line:match("^[%=%+%-%*%/%%%!%^%&%|]%s*(.-)%s*$")) -- ./anselme.can:1028
parsed["address"] = parsed["address"]:match("^%s*(.-)$") -- ./anselme.can:1029
if not parsed["address"]:match("^" .. pvariable .. "$") then -- ./anselme.can:1030
error("unreasonably invalid variable name (" .. tostring(parsed["address"]) .. "); at line " .. tostring(lineno)) -- ./anselme.can:1031
end -- ./anselme.can:1031
parsed["address"] = (function() -- ./anselme.can:1033
local self = {} -- ./anselme.can:1033
for s in parsed["address"]:gmatch("([^.]*)") do -- ./anselme.can:1033
self[#self+1] = s -- ./anselme.can:1033
end -- ./anselme.can:1033
return self -- ./anselme.can:1033
end)() -- ./anselme.can:1033
elseif line:match("^%~") then -- ./anselme.can:1035
parsed["children"] = {} -- ./anselme.can:1036
parsed["variables"]["seen"] = eval("0") -- ./anselme.can:1037
parsed["variables"]["seen"]["default"] = true -- ./anselme.can:1038
parsed["variables"]["used"] = eval("0") -- ./anselme.can:1039
parsed["variables"]["used"]["default"] = true -- ./anselme.can:1040
if not line:match("^%~%~") then -- ./anselme.can:1041
parsed["type"] = "redirection" -- ./anselme.can:1042
parsed["expression"] = expression(parsed, line:match("^%~%s*(.-)%s*$")) -- ./anselme.can:1043
table["insert"](parent["children"], { -- ./anselme.can:1045
["type"] = "redirections", -- ./anselme.can:1046
["parent"] = parent, -- ./anselme.can:1047
["children"] = {}, -- ./anselme.can:1048
["parentParagraph"] = parentParagraph, -- ./anselme.can:1049
["childrenParagraphs"] = nil, -- ./anselme.can:1050
["condition"] = nil, -- ./anselme.can:1051
["variables"] = {}, -- ./anselme.can:1052
["ignoreChildren"] = nil, -- ./anselme.can:1053
["paragraph"] = nil, -- ./anselme.can:1054
["noInsert"] = nil, -- ./anselme.can:1055
["line"] = lineno -- ./anselme.can:1056
}) -- ./anselme.can:1056
table["insert"](parent["children"][# parent["children"]]["children"], parsed) -- ./anselme.can:1058
parsed["noInsert"] = true -- ./anselme.can:1059
else -- ./anselme.can:1059
parsed["type"] = "elseredirection" -- ./anselme.can:1061
local cond = line:match("^%~%~%s*(.-)%s*$") -- ./anselme.can:1062
if cond == "" then -- ./anselme.can:1063
cond = "yes" -- ./anselme.can:1063
end -- ./anselme.can:1063
parsed["expression"] = expression(parsed, cond) -- ./anselme.can:1064
if parent["children"][# parent["children"]] == nil or parent["children"][# parent["children"]]["type"] ~= "redirections" then -- ./anselme.can:1065
error("reached a ~~ else condition but, to the best of our knowledge, there's no ~ if redirection before it; at line " .. tostring(lineno)) -- ./anselme.can:1066
end -- ./anselme.can:1066
table["insert"](parent["children"][# parent["children"]]["children"], parsed) -- ./anselme.can:1068
parsed["noInsert"] = true -- ./anselme.can:1069
end -- ./anselme.can:1069
else -- ./anselme.can:1069
parsed["type"] = "text" -- ./anselme.can:1073
parsed["text"] = line:match("^%s*(.-)%s*$") -- ./anselme.can:1074
parsed["variables"]["seen"] = eval("0") -- ./anselme.can:1075
parsed["variables"]["seen"]["default"] = true -- ./anselme.can:1076
end -- ./anselme.can:1076
if not parsed["noInsert"] then -- ./anselme.can:1079
parent = parsed["parent"] -- ./anselme.can:1080
table["insert"](parent["children"], parsed) -- ./anselme.can:1081
end -- ./anselme.can:1081
if parsed["paragraph"] then -- ./anselme.can:1084
parsed["childrenParagraphs"] = {} -- ./anselme.can:1085
table["insert"](parentParagraph["childrenParagraphs"], parsed) -- ./anselme.can:1086
end -- ./anselme.can:1086
lastParsed = parsed -- ./anselme.can:1089
end -- ./anselme.can:1089
until true -- ./anselme.can:1089
end -- ./anselme.can:1089
return { -- ./anselme.can:1094
["getAST"] = function(self) -- ./anselme.can:1096
return root -- ./anselme.can:1097
end, -- ./anselme.can:1097
["registerFunction"] = function(self, name, func) -- ./anselme.can:1112
engineRegistry[name] = func -- ./anselme.can:1113
end, -- ./anselme.can:1113
["new"] = function(self) -- ./anselme.can:1120
return coroutine["wrap"](function() -- ./anselme.can:1121
run(root["children"]) -- ./anselme.can:1122
return "end" -- ./anselme.can:1123
end) -- ./anselme.can:1123
end -- ./anselme.can:1123
} -- ./anselme.can:1123
end -- ./anselme.can:1123
return anselme -- ./anselme.can:1129

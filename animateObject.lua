local upd = Game.update
local dt_table = {}

--[[To use this:

1. Familarize yourself with dt_table:
- It is a table consisting of other small tables, which go like this {"object_key", "delta_time", "endX", "endY", "animateType", "startX", "startY", "specificCard"}
+ object_key: Used to tell the function what sprite to animate. 
+ delta_time: Basically being the "wait" inbetween every frame.
+ endX: Tell the code to skip to Y when X reaches endX.
+ endY: Tell the code to do its stuff when Y reaches endY, depending on animateType.
+ startX: The reverse of endX. Default is 0.
+ endX: The reverse of endX. Default is 0.
+ specificCard: Only change one card instead of all cards of the same key. If left undeclared, it will resort to object_key instead.
+ animateType:
  - "loop" (default): After running through the entire spritesheet, go back to x = 0, y = 0 and repeat the cycle.
  - "once": After running through the entire spritesheet, go back to x = 0, y = 0.
  - "random": x (0 to endX) and y (0 to endY) is changed randomly.

2. Add the card you want into dt_table, example is left below:
AddRunningAnimation({"j_joker",0.1,1,0}) <-- This probably won't work, see it as a format instead.

3. thats probably it, idk
]]

function GetRunningAnimations()
    return dt_table
end

function SetRunningAnimations(a)
    dt_table = a
end

function AddRunningAnimation(a)
    if type(a) == "table" then
        dt_table[#dt_table+1] = a
    end
end

function Game:update(dt)
    upd(self, dt)
    if dt_table and #dt_table > 0 then
        for index,stuff in pairs(dt_table) do
            if not stuff["currentdt"] then
                stuff["currentdt"] = 0
            end
            stuff["currentdt"] = stuff["currentdt"] + dt
            --print(stuff["currentdt"].." "..stuff[2])
            if G.P_CENTERS and (G.P_CENTERS[stuff[1]] or stuff[8]) and stuff["currentdt"] >= stuff[2] then
                stuff["currentdt"] = 0
                local obj = stuff[8] or G.P_CENTERS[stuff[1]]
                local maxX = stuff[3] or 0
                local maxY = stuff[4] or 0
                local startX = stuff[6] or 0
                local startY = stuff[7] or 0
                local animateType = stuff[5] or "loop"
                if animateType ~= "loop" and animateType ~= "once" and animateType ~= "random" then
                    print("Automatically setting this to loop, are you sure you did it right?: "..animateType)
                    animateType = "loop"
                end
                --card.children.center:set_sprite_pos({x = 0, y = 0})
                if stuff[8] then
                    if not stuff["currentX"] then stuff["currentX"] = startX end
                    if not stuff["currentY"] then stuff["currentY"] = startY end
                    if animateType == "loop" or animateType == "once" then
                        if stuff["currentX"] >= maxX and stuff["currentY"] >= maxY then
                            stuff["currentX"] = startX
                            stuff["currentY"] = startY
                            obj.children.center:set_sprite_pos({x = stuff["currentX"], y = stuff["currentY"]})
                            if animateType == "once" then
                                dt_table[index] = nil
                                goto continue
                            end
                        elseif stuff["currentX"] < maxX then
                            stuff["currentX"] = stuff["currentX"]+ 1
                            obj.children.center:set_sprite_pos({x = stuff["currentX"], y = stuff["currentY"]})
                        elseif stuff["currentY"] < maxY then
                            stuff["currentX"] = startX
                            stuff["currentY"] = stuff["currentY"] + 1
                            obj.children.center:set_sprite_pos({x = stuff["currentX"], y = stuff["currentY"]})
                        end 
                    elseif animateType == "random" then
                        stuff["currentX"] = math.random(startX,maxX)
                        stuff["currentY"] = math.random(startY,maxY)
                        obj.children.center:set_sprite_pos({x = stuff["currentX"], y = stuff["currentY"]})
                    end
                else
                    if animateType == "loop" or animateType == "once" then
                        if obj.pos.x >= maxX and obj.pos.y >= maxY then
                            obj.pos.x = startX
                            obj.pos.y = startY
                            if animateType == "once" then
                                dt_table[index] = nil
                                goto continue
                            end
                        elseif obj.pos.x < maxX then
                            obj.pos.x = obj.pos.x + 1
                        elseif obj.pos.y < maxY then
                            obj.pos.x = startX
                            obj.pos.y = obj.pos.y + 1
                        end 
                    elseif animateType == "random" then
                        obj.pos.x = math.random(startX,maxX)
                        obj.pos.y = math.random(startY,maxY)
                    end
                end
            end
        ::continue::
        end
    end
end
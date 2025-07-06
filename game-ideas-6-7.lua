function _init()
i_plr()
	mx=0
	my=0
	cam_x=0
	cam_y=0
	
	wall=0
	key=1
	door=2
	potion=4
	win=7
	box={
	x=32,
	y=32,
	x2=88,
	y2=88,
	}
end

function _update()
    --animate
 mine_plr()
	move_player()
	

end

function _draw()
	cls()
	draw_map()
	draw_plr()
	check_win_lose()
	
	if false then
	
		-- draw camera box
		rect(box.x,box.y,box.x2,box.y2)
		print("x: "..plr.x,4,4,7)
		print("y: "..plr.y,4,12,11)
	
		-- draw player box
		rect(plr.x, plr.y, plr.x + plr.w - 1, plr.y + plr.h - 1, 8)

		-- highlight tile being checked for interaction (now using centre)
		local px = plr.x + plr.w / 2
		local py = plr.y + plr.h / 2
		local tx = flr((px + cam_x) / 8)
		local ty = flr((py + cam_y) / 8)
		local sx = tx * 8 - cam_x
		local sy = ty * 8 - cam_y
		rect(sx, sy, sx + 7, sy + 7, 11)
	end
	

	local inv_text = "inventory"
	local keys_text = "keys:"..plr.keys
	local potions_text = "potions:"..plr.potions

	-- calculate the width of the widest line (for right alignment)
	local max_width = max(#inv_text, #keys_text, #potions_text) * 4
	local x = 128 - max_width - 1  -- 1-pixel padding from right
	local y = 1

	print(inv_text, x-8, y+8, 0)           -- black (colour 0)
	print(keys_text, x-8, y + 16, 7)      -- white
	print(potions_text, x-8, y + 24, 7)  -- white

	if (btn(❎)) show_inventory()

	--rectfill(0,0,127,15,8)
end




	-- scrolling map --
--	if plr.x >=60 and plr.x <=189 then
--		cam_x= plr.x -60
--	end
--	if plr.y >=60 and plr.y <=189 then
--		cam_y= plr.y -60
--	end
--	if plr.x > 127 then
--		cam_x=128
--	else 
--	cam_x=0
--	end

  
-->8
-- player movement
function i_plr()
	plr={
	 sprite = 1,
	 msprite=10,
		x = 63,
		y = 63,
		ox=60,
		oy=60,
		w=8,
		h=8,
		keys=0,
		potions=0,
		flp=false,
		state = "idle",
		mining=false,
		facing="right",
		timing = 0.15,
		mtiming=0.01
		}
	cam_x=0
	cam_y=0
	
	mapx=flr(plr.x/16)*16
	mapy=flr(plr.y/16)*16
	
	box={
	x=32,
	y=32,
	x2=88,
	y2=88,
	}
end



function move_player()
	-- set default state
	-- only reset to idle if not already mining
if plr.state != "mining" then
  plr.state = "idle"
end


	-- check movement input and update position/state
	plr.ox = plr.x
	plr.oy = plr.y

	if btn(⬅️) and can_move(plr.x - 1, plr.y) then
		plr.x -= 1
		plr.flp = true
		plr.facing = "left"
		plr.state = "walk"
	elseif btn(➡️) and can_move(plr.x + 1, plr.y) then
		plr.x += 1
		plr.flp = false
		plr.facing = "right"
		plr.state = "walk"
	elseif btn(⬆️) and can_move(plr.x, plr.y - 1) then
		plr.y -= 1
		plr.facing = "up"
		plr.state = "walk"
	elseif btn(⬇️) and can_move(plr.x, plr.y + 1) then
		plr.y += 1
		plr.facing = "down"
		plr.state = "walk"
	end
	

	if map_collide(plr.x, plr.y, plr.w, plr.h) then
		plr.x = plr.ox
		plr.y = plr.oy
	end

	cam_move()
	interact(plr.x, plr.y)
	animate_plr()
end


function animate_plr()
	if plr.state == "walk" then
		if plr.sp < 4.6 then
			plr.sp += 0.2
		else
			plr.sp = 1
		end
	elseif plr.state == "mining" then
		plr.sp = 10
		plr.state = "idle"
		print("mining!", 0, 10, 8)
	
 -- single mining frame
	else
		plr.sp = 6 -- idle frame
	end
end


function cam_move()
	 if plr.x < box.x then
 	plr.x =box.x
 	cam_x-=1
 elseif plr.x > box.x2 then
 	plr.x =box.x2
 	cam_x+=1
 end
 
 if cam_x <=0 then
 	cam_x=0
 	box.x=0
 elseif cam_x >= 128 then
 	cam_x=128
 	box.x2=127
 else
 	box.x=32
 	box.x2=88
 end
 
 if cam_y <=0 then
		cam_y=0
		box.y=0
 elseif cam_y >= 128 then
 	cam_y=128
 	box.y2=127
 else
 	box.y=32
 	box.y2=88
 end
 
 if plr.y < box.y then
 	plr.y =box.y
 	cam_y-=1
 elseif plr.y > box.y2 then
 	plr.y =box.y2
 	cam_y+=1
 end
end

function draw_plr()
	spr(flr(plr.sp), plr.x, plr.y, 1, 1, plr.flp, false)
end




-->8
function draw_map()
	camera(cam_x, cam_y)
	palt(0, false)
	palt(15, true)
	map(mx,my)
	palt(0, true)
	palt(15, false)
	camera(0, 0)
end

function map_collide(x,y,w,h)

	x+= cam_x
	y+= cam_y
	
	s1=mget(x/8,y/8)
	s2=mget((x+w-1)/8,y/8)
	s3=mget(x/8,(y+w-1)/8)
	s4=mget((x+w-1)/8,(y+w-1)/8)
	
	if fget(s1,3) or fget(s2,3) or fget(s3,3) or fget(s4,3) then
		return true
	end
	return false
end

function is_tile(tile_type, x, y)
local tile = mget(flr((x + cam_x) / 8), flr((y + cam_y) / 8))	return fget(tile, tile_type)
end


function check_win_lose()
	if is_tile(win, plr.x, plr.y) then
	--print("win", 4, 26, 11)
else
	--print("lose", 4, 34, 11)
end

end


function swap_tile(x,y)
	tile=mget(x,y)
	mset(x,y,tile+1)
end

function upswap_tile(x,y)
	tile=mget(x,y)
	mset(x,y,tile-1)
	mset(tx,ty,8)
end

function get_key(tx, ty)
	plr.keys += 1
	swap_tile(tx, ty)
end

function open_door(tx, ty)
	plr.keys -= 1
	swap_tile(tx, ty)
	mset(tx,ty,22)
end

function get_potion(tx, ty)
	plr.potions += 1
	swap_tile(tx, ty)
end

function interact()
	local px = plr.x + plr.w / 2
	local py = plr.y + plr.h / 2
	local tx = flr((px + cam_x) / 8)
	local ty = flr((py + cam_y) / 8)

	if fget(mget(tx, ty), key) then
		get_key(tx, ty)
		print("picked up key", 4, 42, 10)
	elseif fget(mget(tx, ty), door) and plr.keys > 0 then
		open_door(tx, ty)
		print("opened door", 4, 50, 10)
	elseif fget(mget(tx, ty), potion) then
		get_potion(tx, ty)
		print("picked up a piction", 4, 50, 10)
	end
end



-->8
function show_inventory()
	local x = plr.x - 10
	local y = plr.y - 20

	print("inventory:", x, y, 0)              -- red (colour 8)
	print("keys:"..plr.keys, x, y + 6, 7)     -- green (colour 11)
	print("potions:"..plr.potions, x, y + 12, 7) -- green
end


function can_move(x,y) 
	-- this function give back a true or false wheter a maptile coordinate is a certain flag or not
	-- in this case we are asking if that map coordinate is a wall
	-- if is_tiel returns true than we want can_move to rerutrn false so we do a trick with the word not that flips a true to a false and vise versa
	--this means that if is_tile = true than can_move gives back false and visa versa
	return not is_tile(wall,x,y)
end



-->8
function break_block(tx, ty)
  local tile = mget(tx, ty)
  
  if tile == 32 then
    mset(tx, ty, 33)
  elseif tile == 33 then
    mset(tx, ty, 48)
  elseif tile == 48 then
    mset(tx, ty, 8)
  end
end

function mine_plr()
	if btnp(🅾️) then
		plr.state = "mining"

		local cx = flr((plr.x + 4 + cam_x) / 8)
		local cy = flr((plr.y + 4 + cam_y) / 8)

		if plr.facing == "right" then
			get_rnd_key(cx + 1, cy)
		elseif plr.facing == "left" then
			get_rnd_key(cx - 1, cy)
		elseif plr.facing == "up" then
			get_rnd_key(cx, cy - 1)
		elseif plr.facing == "down" then
			get_rnd_key(cx, cy + 1)
		end
	end
end


function get_rnd_key(tx, ty)
	local tile = mget(tx, ty)

	if tile == 32 then
		mset(tx, ty, 33)
	elseif tile == 33 then
		mset(tx, ty, 48)
	elseif tile == 48 then
		if rnd() < 0.4 then
			mset(tx, ty, 18) 
		else
			mset(tx, ty, 8) -- normal background
		end
	end
end

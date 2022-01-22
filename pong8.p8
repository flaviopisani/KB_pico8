pico-8 cartridge // http://www.pico-8.com
version 33
__lua__

function _init()
	ball_size = 5
	ball_x = 64
	ball_y = 64
	ball_vx = 3
	ball_vy = 0

	paddle_1_height = 10
	paddle_1_width = 1
	paddle_1_x = 0
	paddle_1_y = 64
	paddle_1_vx = 5
	paddle_1_vy = 5

	paddle_2_height = 10
	paddle_2_width = 1
	paddle_2_x = 127 - paddle_2_width
	paddle_2_y = 64
	paddle_2_vx = 5
	paddle_2_vy = 5

	score_p1 = 0
	score_p1_x = 0
	score_p1_y = 0
	score_p2 = 0
	score_p2_x = 125
	score_p2_y = 0

	x_net = 64
	y1_net = 0
	y2_net = 127
	net_length = 8
	net_width = 1
end

-- x position of ...
function draw_dashed_vline(x, y_1, y_2, length, width)
	local x_width = x+width
	local length_2 = 2*length
	for y=y_1,y_2,length_2 do 
		rectfill(x, y, x_width, y+length)
	end 
end

function draw_ball(x, y, size)
	rectfill(x, y, x+size, y+size)
end

function draw_paddle(x, y, width, length)
	rectfill(x, y, x+width, y+length)
end

function update_ball(x, y, v_x, v_y)
	x = x + v_x
	y = y + v_y
	return x, y
end

-- ob = object bl = block
function detect_block_collision(ob_x, ob_y, ob_width, ob_height,
		bl_x, bl_y, bl_width, bl_height)
	local collide_x = detect_collision_line( ob_x, ob_x+ob_width,
			bl_x, bl_x+bl_width)
	local collide_y = detect_collision_line( ob_y, ob_y+ob_height,
			bl_y, bl_y+bl_height)

	return (collide_y and collide_x) 
end

function detect_collision_line(left_1, right_1, left_2, right_2)
	local ret_val = false
	if (left_1 < right_2) and (right_1 > left_2) then
		ret_val = true
	end
	return ret_val
end

function detect_collision_vert(x_1, y_1, length_1, x_2, y_2, length_2)
	local align = detect_collision_line(y_1, y_1+length_1, y_2, y_2+length_2)
	local ret_val = false
	if align and (x_1 == x_2) then
		ret_val = true
	end
	return ret_val
end

function detect_collision_oriz(x_1, y_1, length_1, x_2, y_2, length_2)
	local align = detect_collision_line(x_1, x_1+length_1, x_2, x_2+length_2)
	local ret_val = false
	if align and (y_1 == y_2) then
		ret_val = true
	end
	return ret_val
end

function _update60()
	ball_x, ball_y = update_ball(ball_x, ball_y, ball_vx, ball_vy)
	-- update_ball(ball_x, ball_y, ball_vx, ball_vy)

	if(detect_block_collision(ball_x, ball_y, ball_size,
				ball_size, paddle_1_x, paddle_1_y, paddle_1_width, paddle_1_height))
	 or (detect_block_collision(ball_x, ball_y, ball_size, ball_size, 
				paddle_2_x, paddle_2_y, paddle_2_width, paddle_2_height)) then
			ball_vx = -ball_vx
			ball_vy = -ball_vy
	end

	if (detect_collision_oriz(ball_x, ball_y+ball_size, ball_size, 0, 127, 128)) then
		ball_vy = -ball_vy
	end
end

function _draw()
	cls()
	draw_dashed_vline(x_net, y1_net, y2_net, net_length, net_width)
	draw_ball(ball_x, ball_y, ball_size)
	draw_paddle(paddle_1_x, paddle_1_y, paddle_1_width, paddle_1_height)
	draw_paddle(paddle_2_x, paddle_2_y, paddle_2_width, paddle_2_height)
	print(score_p1, score_p1_x, score_p1_y)
	print(score_p2, score_p2_x, score_p2_y)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000b000000000000007770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000007b70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000bbb000000000007770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

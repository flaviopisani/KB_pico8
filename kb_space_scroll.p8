pico-8 cartridge // http://www.pico-8.com
version 33
__lua__

function make_spaceship(x, y, v_x, v_y, boost_x, boost_y, height, width, sprite)
	local spaceship = {
		x = x,
		y = y,
		v_x = v_x,
		v_y = v_y,
		boost_x = boost_x,
		boost_y = boost_y,
		height = height,
		width = width,
		sprite = sprite
	}
	return spaceship
end

function make_bullet(x, y, v_x, v_y, color, size)
	local bullet = {
		x = x,
		y = y,
		v_x = v_x,
		v_y = v_y,
		color = color,
		size = size
	}
	return bullet
end

function update_player_spaceship(spaceship, inputs, player_bullets)
	printh("update player")
	spaceship.v_x = inputs.x_axis * spaceship.boost_x
	spaceship.v_y = - (inputs.y_axis * spaceship.boost_y)

	if inputs.but_c then
		fire(spaceship, player_bullets, player_bullet_speed)
	end
	
	update_spaceship(spaceship)
end

function spawn_enemy(enemy_list)
	if rnd() <= enemy_spawn_prob then
		x = rnd(127)
		add(enemy_list,
				make_spaceship(
					x,
					0, 
					0,
					0,
					enemy_boost_x,
					enemy_boost_y,
					enemy_height,
					enemy_width,
					enemy_sprite)
		   )

		-- debug
		printh("creating an enemy")
		printh(type(enemy_list))
		for a in all(enemy_list) do
			printh("aaaaaaaa")
			printh(a.x)
		end
	end
end

function update_enemy_spaceship(spaceship, enemy_bullets)
	printh("update enemy")
	spaceship.v_x = spaceship.boost_x
	spaceship.v_y = spaceship.boost_y

	if rnd() <= enemy_shoot_prob then
		fire(spaceship, enemy_bullets, enemy_bullet_speed)
	end

	update_spaceship(spaceship)

end

function update_spaceship(spaceship)
	spaceship.x += spaceship.v_x
	spaceship.y += spaceship.v_y
end

function draw_spaceship(spaceship)
	spr(spaceship.sprite, spaceship.x, spaceship.y)
end

function draw_bullet(bullet)
	rectfill(bullet.x, bullet.y, bullet.x+bullet.size, bullet.y+bullet.size, 7,7)
end

function update_bullet(bullet)
	bullet.x += bullet.v_x
	bullet.y += bullet.v_y
end

function fire(spaceship, bullets, bullet_speed, bullet_color)
	add(bullets, 
			make_bullet(spaceship.x,
				spaceship.y,
				0,
				bullet_speed,
				bullet_color,
				1)
			)
	printh("FIRE!!!")
	printh(type(bullets[1].v_y))
end

function input_handling()
	local button_mask = btn()
	local inputs = {}
    inputs.but_x = ((button_mask & 0x10) >> 4)
    -- inputs.but_x = btnp(4)
    -- inputs.but_c = ((button_mask & 0x20) >> 5)
    inputs.but_c = btnp(5)

		-- 0 neutral
		-- +1 rigth/up
		-- -1 left/down
    inputs.x_axis = ((button_mask & 0x2) >> 1) - (button_mask & 0x1)
    inputs.y_axis = ((button_mask & 0x4) >> 2) - ((button_mask & 0x8) >> 3 )
	return inputs
end

function detect_block_collision(a_x, a_width, a_y, a_height, 
		b_x, b_width, b_y, b_height)
	local a_left = a_x
	local a_right = a_x + a_width
	local a_top = a_y
	local a_bottom = a_y + a_height
	local b_left = b_x
	local b_right = b_x + b_width
	local b_top = b_y
	local b_bottom = b_y + b_height

	
	return (a_left < b_right) and (a_right > b_left) and
		(a_top < b_bottom) and (a_bottom > b_top) 
end

function bullet_collision(bullet, spaceship)
	return detect_block_collision(bullet.x, bullet.size, bullet.y, bullet.size,
			spaceship.x, spaceship.width, spaceship.y, spaceship.height)
end

function spaceship_collision(spaceship_a, spaceship_b)
	return detect_block_collision(spaceship_a.x, spaceship_a.width, 
			spaceship_a.y, spaceship_a.height,
			spaceship_b.x, spaceship_b.width, 
			spaceship_b.y, spaceship_b.height)
end

function _init()
	speed_factor = 2
	score = 0
	game_over = false
	player_bullet_speed = -1*speed_factor
	boost_x = 0.5*speed_factor
	boost_y = 0.5*speed_factor
	player_height = 8
	player_width = 8
	player_sprite = 0
	player_start_x = 0
	player_start_y = 127 - player_height
	player_start_v_x = 0
	player_start_v_y = 0
	player_spaceship = make_spaceship(
			player_start_x,
			player_start_y,
			player_start_v_x,
			player_start_v_y,
			boost_x,
			boost_y,
			player_height,
			player_width,
			player_sprite
			)
	enemy_boost_x = 0*speed_factor
	enemy_boost_y = 0.5*speed_factor
	enemy_height = 8
	enemy_width = 8
	enemy_sprite = 1
	enemy_spawn_prob = 0.005
	enemy_shoot_prob = 0.01
	enemy_bullet_speed = 1*speed_factor

	-- lists
	enemy_spaceships = {}
	enemy_bullets = {}
	player_bullets = {}
end

function _update60()
	game_over = false

	local inputs = input_handling()
	
	spawn_enemy(enemy_spaceships)

	for a in all(enemy_spaceships) do 
		printh("UPDATE")
		printh(a.x)
	end

	update_player_spaceship(player_spaceship, inputs, player_bullets)
	for spaceship in all(enemy_spaceships) do
		update_enemy_spaceship(spaceship, enemy_bullets)
		if spaceship.y >= 128 then
			del(enemy_spaceships, spaceship)
		end
		if spaceship_collision(player_spaceship, spaceship) then
			game_over = true
		end
	end

	print(type(player_bullets))

	for bullet in all(player_bullets) do
		update_bullet(bullet)
		if bullet.y <= 0 then
			del(player_bullets, bullet)
		end
		for spaceship in all(enemy_spaceships) do
			if bullet_collision(bullet, spaceship) then
				del(enemy_spaceships, spaceship)
				del(player_bullets, bullet)
				score += 1
			end
		end
	end

	for bullet in all(enemy_bullets) do
		update_bullet(bullet)
		if bullet.y >= 128 then
			del(enemy_bullets, bullet)
		end
		if bullet_collision(bullet, player_spaceship) then
			game_over = true
		end
	end
	
end

function _draw()
	cls()
	print(score)

	if game_over then
		print("GAME OVER")
	end
	-- else
		draw_spaceship(player_spaceship)

		for spaceship in all(enemy_spaceships) do
			printh("draw enemy")
			draw_spaceship(spaceship)
		end

		for bullet in all(player_bullets) do
			draw_bullet(bullet)
		end

		for bullet in all(enemy_bullets) do
			draw_bullet(bullet)
		end
	-- end
end
__gfx__
00077000044444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0077770044c44c440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777044444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

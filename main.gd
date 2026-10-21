extends Node2D
# WAKE ME UP BEFORE YOU GUN-GUN  -  Chumplee's 80s arcade rescue
const W := 384
const H := 216
const GROUND := 184.0
const LEVEL_END := 3400.0
const ARENA := LEVEL_END - W
var font: Font
var tex := {}
var snd := {}
var music: AudioStreamPlayer
var sfx_players := []
var state := "title"
var st := 0.0  # time in state
var hiscore := 0
var score := 0
var lives := 3
var hp := 5
var cam_x := 0.0
var shake := 0.0
var flash := 0.0
var prev_keys := {}
var mode := ""
var god := false
var bot_jump_t := 0.0
# player
var pp := Vector2(40, GROUND)
var pv := Vector2.ZERO
var on_ground := true
var facing := 1
var inv := 0.0
var shoot_cd := 0.0
var spread := 0.0
var run_anim := 0.0
var dead_t := 0.0
# world
var platforms := []
var spawns := []
var enemies := []
var pbul := []
var ebul := []
var parts := []
var pickups := []
var floats := []
# boss
var boss := {}
var boss_active := false
var taunt := ""
var taunt_t := 0.0
var cont_t := 0.0
var bossdead_t := 0.0

const CONTROLS := "A/D MOVE  SPACE JUMP  J SHOOT  W AIM UP"
const TAUNTS := ["TALK TO THE SHOULDER PADS!", "YOU CALL THAT AIR GUITAR?", "KEL-BALL, GO!!", "HAIRSPRAY FIRST, QUESTIONS LATER!", "I'VE GOT MORE ORBS THAN YOU'VE GOT FRIENDS!", "CARELESS, CHUMPLEE. VERY CARELESS.", "THIS IS MY SUMMER TOUR NOW, HONEY!", "NICE HEADBAND. DID YOUR MOM PICK IT?"]

# ---------------- sprites ----------------
const PAL := {
	"k": Color("#0a0a12"), "w": Color("#ffffff"), "s": Color("#f6c08a"), "S": Color("#c07850"), "h": Color("#6a3a1a"),
	"y": Color("#ffd860"), "Y": Color("#ffe020"), "b": Color("#3058d0"), "r": Color("#e8203c"), "p": Color("#ff3fa8"),
	"c": Color("#30e8ff"), "g": Color("#9090a0"), "G": Color("#40e060"), "o": Color("#ff9020"), "n": Color("#2a1a14"),
	"v": Color("#7a2ac0"), "d": Color("#3c3c4c"), "m": Color("#9a6430"), "B": Color("#3aa0ff"), "K": Color("#241828"),
	"f": Color("#fff4f6"), "e": Color("#b0b0b8")}
const CH_TOP := ["......nnnnnn......", "....nnnnnnnnnn....", "...nnnnnnnnnnnn...", "...nssssssssssn...", "..ssskkkkskkkkss..", "..sskkkkkkkkkkss..", "..ssskkkssskkkss..", "..ssssssSsssssss..", "..ssnnnnnnnnnsss..", "...ssssnwwwnsss...", "....ssnnnnnss.....", "..ssssssssssssss..", ".KKKKrKKKKKKrKKKK.", "KKKKKKrKKKKrKKKKKK", "sKKKKKKrKKrKKKKKKs", "sKKKKKKKrrKKKKKKKs", "sKKKKKKKgwKKKKKKKs", "sKKKKKKKKKKKKKKKKs", ".sKKKKKKKKKKKKKKs.", "..KKKKKKKKKKKKKK..", "...dddddddddddd..."]
const CH_LEGS := [["...dddd...dddd....", "...dddd...dddd....", "..kkkkk...kkkkk..."], ["..dddd.....dddd...", "..ddd.......ddd...", ".kkkk.......kkkk.."], ["....ddddddddd.....", "....ddddddd.......", "....kkkkkkk......."]]
const CH_JUMP_LEGS := ["..dddd....dddd....", "..dd........dd....", "..kk........kk...."]
const CH_ROCK := ["......nnnnnn......", "....nnnnnnnnnn....", "...nnnnnnnnnnnn...", "...nssssssssssn...", "..ssskkkkskkkkss..", "..sskkkkkkkkkkss..", "..ssskkkssskkkss..", "..ssssssSsssssss..", "..ssnnnnnnnnnsss..", "...ssssnwwwnsss...", "....ssnnnnnss.....", "s.ssssssssssssss.s", ".sKKKrKKKKKKrKKKs.", "..KKKKrKKKKrKKKK..", ".KKKKKKrKKrKKKKKK.", "KKKKKKKKrrKKKKKKKK", "KKKKKKKKgwKKKKKKKK", "KKKKKKKKKKKKKKKKKK", ".KKKKKKKKKKKKKKKK.", "..KKKKKKKKKKKKKK..", "...dddddddddddd..."]
const CH_FALL := ["......nnnnnn......", "....nnnnnnnnnn....", "...nnnnnnnnnnnn...", "...nssssssssssn...", "..ssskkkkskkkkss..", "..sskkkkkkkkkkss..", "..ssskkkssskkkss..", "..ssssssSsssssss..", "..ssnnnnnnnnnsss..", "...ssssnwwwnsss...", "....ssnnnnnss.....", "s.ssssssssssssss.s", ".sKKKrKKKKKKrKKKs.", "..KKKKrKKKKrKKKK..", ".KKKKKKrKKrKKKKKK.", "KKKKKKKKrrKKKKKKKK", "KKKKKKKKgwKKKKKKKK", "KKKKKKKKKKKKKKKKKK", ".KKKKKKKKKKKKKKKK.", "..KKKKKKKKKKKKKK..", "...dddddddddddd...", "..dddd....dddd....", "..dd........dd....", "..kk........kk...."]
const WHAM := ["...HHHHH....", "..HHHHHHHH..", ".HHHHHHHHHH.", ".HHHsssHHHH.", ".HHskssksHH.", "..HsssssHH..", "..HHsrssH...", "...H.ss.....", "..wwwwwww...", ".swwwwwwws..", ".s.wwwwww.s.", "...wwwwww...", "...bbbbbb...", "...bb..bb...", "...bb..bb...", "...bb..bb...", "...ww..ww..."]
const KEL := [".....nnnnnn.....", "...nnnnnnnnnn...", "..nnngnnnnnnnn..", ".nnnnnnnnnngnnn.", ".nnnnnnnnnnnnnn.", ".nnsnnssnnssnnn.", "nnnskkssskksnnnn", "nnnsBwsssBwsnnn.", "nnnsssssssssnnnn", "nngsssssrrssnngn", "nnnnsssrssssnnnn", "nnnnnnssssnnnnnn", "nnnKKKKKKKKKKnnn", "nnKKrKKKKKrKKKnn", ".nKKKKKrKKKKKKn.", ".nsKrKKKKKKrKKs.", "..s.KKKrKKKKK.s.", "....KKKKKKKK....", "....KKK..KKK....", "....KKK..KKK....", "....KKK..KKK....", "...rrrr..rrrr..."]
const THUG := ["...mmmm.....", "..mmmmmm....", "..msssss....", "..mskssk....", "..mmssss....", "..mmsrss....", ".mmm.ss.....", "..bbwwbb....", ".sbbwwbbs...", ".s.bwwb.s...", "...dddd.....", "...dd.dd....", "...dd.dd....", "..kkk.kkk..."]
const PUNK := ["....pp......", "...ppp......", "..pp........", "..sssss.....", "..skssk.....", "..ssssr.....", "...ss.......", "..cccccc....", ".scccccs....", ".s.ccc.s....", "...kkkk.....", "...kk.kk....", "..wwwwwww...", "..r.r..r.r.."]
const BOOM := ["..d........d..", "..dddddddddd..", ".dddddddddddd.", ".dggddddddggd.", ".dgkgdccdgkgd.", ".dggddddddggd.", ".dddddddddddd."]

func mk(name: String, rows: Array) -> void:
	var w := 0
	for r in rows: w = max(w, r.length())
	var img := Image.create(w, rows.size(), false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for y in rows.size():
		var r: String = rows[y]
		for x in r.length():
			var ch := r[x]
			if PAL.has(ch): img.set_pixel(x, y, PAL[ch])
	var img2 := img.duplicate()
	img2.flip_x()
	tex[name] = [ImageTexture.create_from_image(img), ImageTexture.create_from_image(img2)]

func spr(name: String, feet: Vector2, flip := false, mod := Color.WHITE, sc := 2.0) -> void:
	var t: Texture2D = tex[name][1 if flip else 0]
	var w := t.get_width() * sc
	var h := t.get_height() * sc
	draw_texture_rect(t, Rect2(round(feet.x - w / 2.0), round(feet.y - h), w, h), false, mod)

func _ready() -> void:
	font = load("res://fonts/PressStart2P.ttf")
	for i in 3: mk("ch%d" % i, CH_TOP + CH_LEGS[i])
	mk("chj", CH_TOP + CH_JUMP_LEGS)
	mk("rock", CH_ROCK + CH_LEGS[0])
	mk("fall", CH_FALL)
	var wa: Array = []
	var wb: Array = []
	for r in WHAM:
		wa.append(r.replace("H", "y"))
		wb.append(r.replace("H", "h"))
	mk("george", wa); mk("andrew", wb)
	mk("kel", KEL); mk("thug", THUG); mk("punk", PUNK); mk("boom", BOOM)
	for n in ["music_title", "music_level", "music_boss", "music_cutscene", "jingle_win", "jingle_over", "shoot", "jump", "hit", "explode", "hurt", "powerup", "select", "glass", "crash", "orb", "wind", "bosshit", "taunt"]:
		var s: AudioStreamWAV = load("res://audio/%s.wav" % n)
		if n.begins_with("music") or n == "wind":
			s = s.duplicate()
			s.loop_mode = AudioStreamWAV.LOOP_FORWARD
			s.loop_end = int(s.get_length() * s.mix_rate)
		snd[n] = s
	snd["scratch"] = load("res://audio/scratch.wav")
	for n in ["music_wgogo", "music_cw", "music_lc"]:
		var o: AudioStreamOggVorbis = load("res://audio/%s.ogg" % n)
		o = o.duplicate(); o.loop = n != "music_cw"; snd[n] = o
	music = AudioStreamPlayer.new(); add_child(music); music.volume_db = -6
	for i in 8:
		var p := AudioStreamPlayer.new(); add_child(p); sfx_players.append(p); p.volume_db = -4
	if FileAccess.file_exists("user://hi.dat"):
		var f := FileAccess.open("user://hi.dat", FileAccess.READ); hiscore = f.get_32()
	hiscore = max(hiscore, 25000)
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--shot="): mode = a.substr(7)
		if a == "--auto": mode = "auto"
		if a.begins_with("--test="): mode = "test_" + a.substr(7)
	set_state("title")
	if mode in ["cutscene", "fall", "concert"]: set_state("cut")
	if mode in ["level", "auto", "boss", "reunion"]: start_game()
	if mode == "reunion": god = true; pp.x = ARENA + 60; cam_x = ARENA; start_boss(); boss.st = "orbs"; boss.p.y = GROUND; boss_defeated()
	if mode.begins_with("test_"): start_test()
	if mode in ["auto", "boss", "level"] or mode.begins_with("test_"): god = true

func play_music(n: String) -> void:
	if music.stream != snd[n]:
		music.stream = snd[n]; music.play()
func sfx(n: String) -> void:
	for p in sfx_players:
		if not p.playing:
			p.stream = snd[n]; p.play(); return
	sfx_players[0].stream = snd[n]; sfx_players[0].play()

func set_state(s: String) -> void:
	state = s; st = 0.0
	match s:
		"title": play_music("music_wgogo")
		"cut": music.stream = snd["music_cw"]; music.play(); parts.clear(); cut_flags.clear()
		"card": music.stop()
		"play": play_music("music_boss" if boss_active else "music_level")
		"win":
			if music.stream != snd["music_lc"] or not music.playing: music.stream = snd["jingle_win"]; music.play()
			save_hi()
		"cont": music.stream = snd["jingle_over"]; music.play()
		"over": save_hi()

func save_hi() -> void:
	if score > hiscore and mode == "":
		hiscore = score
		var f := FileAccess.open("user://hi.dat", FileAccess.WRITE)
		if f: f.store_32(hiscore)

func kd(k: int) -> bool: return Input.is_physical_key_pressed(k)
func kh(k: int) -> bool:
	return kd(k) and not prev_keys.get(k, false)
func enter_hit() -> bool: return kh(KEY_ENTER) or kh(KEY_KP_ENTER)

# ---------------- game setup ----------------
func start_game() -> void:
	score = 0; lives = 3
	reset_level()
	set_state("card" if mode == "" else "play")
	if mode == "boss": pp.x = ARENA + 90; cam_x = ARENA

func reset_level() -> void:
	hp = 5; pp = Vector2(40, GROUND); pv = Vector2.ZERO; cam_x = 0; spread = 0; inv = 0
	enemies.clear(); pbul.clear(); ebul.clear(); parts.clear(); pickups.clear(); floats.clear()
	boss_active = false; boss = {}; bossdead_t = 0
	platforms = []
	var seed_x := [260, 520, 760, 1040, 1300, 1560, 1820, 2100, 2380, 2640]
	for i in seed_x.size():
		var x: float = seed_x[i]
		platforms.append(Rect2(x, 140 - (i % 3) * 18, 70 + (i % 2) * 30, 6))
	platforms.append(Rect2(ARENA + 40, 140, 60, 6)); platforms.append(Rect2(ARENA + 284, 140, 60, 6))
	spawns = []
	var types := ["thug", "punk", "thug", "boom", "punk", "thug", "boom", "boom", "punk", "thug"]
	var x := 340.0; var i2 := 0
	while x < ARENA - 120:
		spawns.append({"x": x, "t": types[i2 % types.size()]})
		if i2 % 4 == 3: spawns.append({"x": x + 30, "t": types[(i2 + 1) % types.size()]})
		x += 150 - min(i2, 8) * 5; i2 += 1
	pickups = [{"p": Vector2(790, 140 - 18 - 2), "k": "tape"}, {"p": Vector2(1340, GROUND - 2), "k": "heart"}, {"p": Vector2(2140, 140 - 18 - 2), "k": "tape"}, {"p": Vector2(2700, GROUND - 2), "k": "heart"}, {"p": Vector2(ARENA - 40, GROUND - 2), "k": "heart"}]

# ---------------- main loop ----------------
var cut_flags := {}
func _process(delta: float) -> void:
	var dt: float = min(delta, 1.0 / 30.0)
	st += dt
	shake = max(0.0, shake - dt); flash = max(0.0, flash - dt * 3)
	match state:
		"title":
			if enter_hit(): sfx("select"); set_state("cut")
		"cut": update_cut(dt)
		"card":
			if st > 2.2 or (st > 0.3 and enter_hit()): set_state("play")
		"play": update_play(dt)
		"win":
			if st > 2 and enter_hit(): set_state("title")
		"cont":
			cont_t = 9.99 - st * 1.0
			if enter_hit():
				sfx("select"); lives = 3; hp = 5; score = 0; inv = 2; state = "play"; play_music("music_boss" if boss_active else "music_level")
			elif cont_t <= 0: set_state("over")
		"over":
			if st > 3 or (st > 1 and enter_hit()): set_state("title")
	update_parts(dt)
	for k in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_J, KEY_W, KEY_UP, KEY_Z, KEY_K]: prev_keys[k] = kd(k)
	queue_redraw()
	shots()
	if mode.begins_with("test_"): run_test(dt)

func shots() -> void:
	var targets := {"title": ["title", 2.0], "concert": ["cut", 33.0], "cutscene": ["cut", CONCERT + 3.6 * SLOW], "fall": ["cut", CONCERT + 10.0 * SLOW], "level": ["play", 2.5], "boss": ["play", 6.0]}
	if mode == "reunion" and state == "play" and bossdead_t > 22.0 and not cut_flags.has("shot"):
		cut_flags["shot"] = true
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("/workspace/chumplee-reunion.png"); print("saved reunion")
	if mode == "reunion" and state == "win": print("REUNION reached win st=", snapped(Time.get_ticks_msec() / 1000.0, 0.1), " music=", music.stream.resource_path, " playing=", music.playing, " pos=", snapped(music.get_playback_position(), 0.1)); get_tree().quit()
	if targets.has(mode) and state == targets[mode][0] and st >= targets[mode][1]:
		if mode == "level" and pp.x < 1000:
			pp.x = 1180; cam_x = 1100; st = 0.5; return
		var out: String = {"title": "chumplee-title", "cutscene": "chumplee-cutscene", "concert": "chumplee-concert", "fall": "chumplee-fall", "level": "chumplee-level", "boss": "chumplee-boss"}[mode]
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("/workspace/%s.png" % out)
		print("saved ", out); get_tree().quit()
	if mode == "auto":
		if state == "win": print("AUTO RESULT: WIN score=", score, " time=", Time.get_ticks_msec()); get_tree().quit()
		if state in ["cont", "over"]: print("AUTO RESULT: DIED"); get_tree().quit()
		if Time.get_ticks_msec() > 600000: print("AUTO RESULT: TIMEOUT x=", pp.x); get_tree().quit()

func add_parts(p: Vector2, n: int, col: Color, spd := 80.0, life := 0.6, size := 2.0) -> void:
	for i in n:
		var a := randf() * TAU
		parts.append({"p": p, "v": Vector2(cos(a), sin(a)) * randf_range(spd * 0.3, spd), "l": life * randf_range(0.5, 1.0), "c": col, "s": size})
func update_parts(dt: float) -> void:
	for q in parts:
		q.p += q.v * dt; q.v.y += 120 * dt; q.l -= dt
	parts = parts.filter(func(q): return q.l > 0)
	for f in floats:
		f.p.y -= 20 * dt; f.l -= dt
	floats = floats.filter(func(f): return f.l > 0)

func add_score(n: int, at: Vector2) -> void:
	score += n; floats.append({"p": at, "t": str(n), "l": 0.8})

# ---------------- input/bot ----------------
func inp() -> Dictionary:
	var d := {"l": kd(KEY_A) or kd(KEY_LEFT), "r": kd(KEY_D) or kd(KEY_RIGHT), "u": kd(KEY_W) or kd(KEY_UP), "jump": kh(KEY_SPACE) or kh(KEY_K), "jh": kd(KEY_SPACE) or kd(KEY_K), "shoot": kd(KEY_J) or kd(KEY_Z)}
	if mode == "auto":
		bot_jump_t -= get_process_delta_time()
		d = {"l": false, "r": true, "u": false, "jump": false, "jh": true, "shoot": true}
		if boss_active and not boss.is_empty():
			var bx: float = boss.p.x
			d.r = pp.x < bx - 90; d.l = pp.x > bx - 60 and pp.x > ARENA + 20
			if pp.x > bx: d.l = true; d.r = false
			d.u = boss.p.y < 120 and abs(boss.p.x - pp.x) < 40
		for e in enemies:
			if e.t == "boom" and abs(e.p.x - pp.x) < 30: d.u = true
		if bot_jump_t <= 0 and on_ground:
			bot_jump_t = randf_range(0.5, 1.4); d.jump = true
	return d

# ---------------- play ----------------
func update_play(dt: float) -> void:
	if bossdead_t > 0:
		update_bossdead(dt); return
	var i := inp()
	inv = max(0.0, inv - dt); shoot_cd -= dt
	# power-up timer is frozen during the boss entrance so the spread shot carries into the fight
	if not (boss_active and not boss.is_empty() and boss.st == "intro"): spread = max(0.0, spread - dt)
	var mx := 0.0
	if i.l: mx -= 1
	if i.r: mx += 1
	if mx != 0: facing = int(mx)
	pv.x = mx * 95
	if i.jump and on_ground:
		pv.y = -300; on_ground = false; sfx("jump")
	if not i.jh and pv.y < -100: pv.y = -100
	pv.y = min(pv.y + 640 * dt, 400)
	var oldy := pp.y
	pp += pv * dt
	var lo := cam_x + 18
	var hi_x := (ARENA + W - 18) if boss_active else (LEVEL_END - 18)
	pp.x = clamp(pp.x, lo, hi_x)
	on_ground = false
	if pp.y >= GROUND: pp.y = GROUND; pv.y = 0; on_ground = true
	if pv.y >= 0:
		for r in platforms:
			if pp.x > r.position.x - 7 and pp.x < r.end.x + 7 and oldy <= r.position.y + 0.5 and pp.y >= r.position.y:
				pp.y = r.position.y; pv.y = 0; on_ground = true
	run_anim += dt * (10.0 if mx != 0 else 0.0)
	# camera
	if not boss_active:
		cam_x = clamp(max(cam_x, pp.x - 150), 0, ARENA)
		if pp.x > ARENA + 60: start_boss()
	else:
		cam_x = move_toward(cam_x, ARENA, 200 * dt)
	# shoot
	if i.shoot and shoot_cd <= 0:
		shoot_cd = 0.16; sfx("shoot")
		var dir := Vector2(facing, 0)
		if i.u: dir = Vector2(0, -1) if mx == 0 else Vector2(facing, -1).normalized()
		var org := pp + Vector2(facing * 20, -24)
		if i.u and mx == 0: org = pp + Vector2(0, -52)
		var angs := [0.0] if spread <= 0 else [-0.25, 0.0, 0.25]
		for a in angs: pbul.append({"p": org, "v": dir.rotated(a) * 300, "l": 1.0})
	# spawns
	while spawns.size() > 0 and spawns[0].x < cam_x + W + 10:
		var s = spawns.pop_front(); spawn_enemy(s.t)
	update_enemies(dt)
	if boss_active: update_boss(dt)
	update_bullets(dt)
	for pk in pickups:
		if pk.p.distance_to(pp + Vector2(0, -20)) < 24:
			pk.dead = true; sfx("powerup")
			if pk.k == "tape": spread = 15.0; floats.append({"p": pk.p + Vector2(0, -10), "t": "WHAM-POW SPREAD!", "l": 1.5})
			else: hp = min(5, hp + 2); floats.append({"p": pk.p + Vector2(0, -10), "t": "+HP", "l": 1.0})
			add_score(500, pk.p)
	pickups = pickups.filter(func(p): return not p.has("dead"))

func spawn_enemy(t: String) -> void:
	var e := {"t": t, "hp": 3, "tm": randf_range(0.8, 2.0), "fl": 0.0}
	match t:
		"thug": e.p = Vector2(cam_x + W + 8, GROUND); e.hp = 4
		"punk": e.p = Vector2(cam_x + W + 8, GROUND); e.hp = 2
		"boom": e.p = Vector2(cam_x + W + 8, randf_range(50, 80)); e.hp = 2; e.by = e.p.y
	enemies.append(e)

func hurt_player() -> void:
	if inv > 0 or god: return
	hp -= 1; inv = 1.4; shake = 0.25; sfx("hurt"); add_parts(pp + Vector2(0, -18), 10, PAL.o, 80)
	if hp <= 0:
		lives -= 1; add_parts(pp + Vector2(0, -18), 30, PAL.r, 140, 1.0)
		if lives <= 0: set_state("cont")
		else: hp = 5; inv = 2.5; floats.append({"p": pp + Vector2(0, -26), "t": "OUCH! LIFE LOST", "l": 1.5})

func update_enemies(dt: float) -> void:
	for e in enemies:
		e.fl = max(0.0, e.fl - dt); e.tm -= dt
		match e.t:
			"thug":
				var d: float = sign(pp.x - e.p.x)
				if abs(pp.x - e.p.x) > 50: e.p.x += d * 32 * dt
				if e.tm <= 0 and abs(pp.x - e.p.x) < 260:
					e.tm = 2.2; ebul.append({"p": e.p + Vector2(d * 12, -18), "v": Vector2(d * 120, 0), "k": "bullet"})
			"punk":
				e.p.x -= 115 * dt
			"boom":
				e.p.x += sign(pp.x - e.p.x) * 38 * dt
				e.p.y = e.by + sin(st * 3 + e.by) * 10
				if e.tm <= 0 and abs(pp.x - e.p.x) < 150:
					e.tm = 1.7; ebul.append({"p": e.p, "v": Vector2(sign(pp.x - e.p.x) * 40, 60), "k": "note"})
		var hb := Rect2(e.p.x - (14 if e.t == "boom" else 9), e.p.y - (14 if e.t == "boom" else 28), 28 if e.t == "boom" else 18, 14 if e.t == "boom" else 28)
		if hb.intersects(Rect2(pp.x - 14, pp.y - 44, 28, 42)): hurt_player()
		e.hb = hb
	enemies = enemies.filter(func(e): return e.hp > 0 and e.p.x > cam_x - 40)

func update_bullets(dt: float) -> void:
	for b in pbul:
		b.p += b.v * dt; b.l -= dt
		for e in enemies:
			if e.hp > 0 and e.hb.grow(2).has_point(b.p):
				e.hp -= 1; e.fl = 0.1; b.l = 0; sfx("hit"); add_parts(b.p, 4, PAL.Y, 60, 0.3)
				if e.hp <= 0:
					sfx("explode"); add_parts(e.p + Vector2(0, -8), 18, [PAL.p, PAL.c, PAL.Y][randi() % 3], 120, 0.7)
					add_score({"thug": 100, "punk": 150, "boom": 200}[e.t], e.p + Vector2(0, -20))
					if randf() < 0.08: pickups.append({"p": Vector2(e.p.x, GROUND - 2), "k": "heart"})
				break
		if b.l > 0 and boss_active and not boss.is_empty() and boss.st != "intro" and Rect2(boss.p.x - 16, boss.p.y - 44, 32, 44).has_point(b.p):
			b.l = 0; boss.hp -= 1; boss.fl = 0.08; sfx("bosshit"); add_parts(b.p, 3, PAL.Y, 50, 0.3); score += 10
			if boss.hp <= 0: boss_defeated()
	pbul = pbul.filter(func(b): return b.l > 0 and b.p.x > cam_x - 10 and b.p.x < cam_x + W + 10 and b.p.y > -10)
	for b in ebul:
		b.p += b.v * dt
		if b.k == "orb":
			b.v.y += 300 * dt
			if b.p.y > GROUND - 5 and b.v.y > 0: b.v.y *= -0.7; b.p.y = GROUND - 5; b.bn = b.get("bn", 0) + 1
		if b.p.distance_to(pp + Vector2(0, -20)) < (14 if b.k == "orb" else 11): hurt_player(); b.dead = true
	ebul = ebul.filter(func(b): return not b.has("dead") and b.get("bn", 0) < 3 and b.p.x > cam_x - 20 and b.p.x < cam_x + W + 20 and b.p.y < H + 10)

# ---------------- boss ----------------
func start_boss() -> void:
	boss_active = true; play_music("music_boss")
	enemies.clear(); spawns.clear()
	boss = {"p": Vector2(ARENA + 300, -40), "hp": 70, "max": 70, "st": "intro", "t": 0.0, "fl": 0.0, "dir": -1, "n": 0}
	say("KELDARAH: WELL WELL... IF IT ISN'T CHUMPLEE!")
func say(t: String) -> void:
	taunt = t; taunt_t = 2.6; sfx("taunt")
func update_boss(dt: float) -> void:
	var b := boss
	b.t += dt; b.fl = max(0.0, b.fl - dt); taunt_t -= dt
	var fast: bool = b.hp < b.max / 2
	match b.st:
		"intro":
			b.p.y = move_toward(b.p.y, GROUND, 120 * dt)
			if b.t > 2.6: next_attack()
		"orbs":
			if b.t > b.next_throw and b.n > 0:
				b.n -= 1; b.next_throw = b.t + (0.45 if fast else 0.7); sfx("orb")
				var dx: float = pp.x - b.p.x
				ebul.append({"p": b.p + Vector2(0, -36), "v": Vector2(dx * randf_range(0.8, 1.3), -200), "k": "orb"})
			if b.t > 3.2: next_attack()
		"dash":
			# wind-up shake is drawn as a visual offset only (it used to move her real position and drift her past the wall)
			if b.t >= 0.7:
				b.p.x += b.dir * (300 if fast else 230) * dt
				if b.t > 0.9 and randf() < 0.3: add_parts(b.p + Vector2(0, -6), 1, PAL.v, 20, 0.4, 3)
				# only end the charge at the wall she is charging toward
				if (b.dir < 0 and b.p.x <= ARENA + 24) or (b.dir > 0 and b.p.x >= ARENA + W - 24):
					b.p.x = clamp(b.p.x, ARENA + 24, ARENA + W - 24); b.dir = -b.dir; next_attack()
		"rain":
			b.p.y = move_toward(b.p.y, 40, 260 * dt)
			if b.t > 0.6 and b.t > b.next_throw and b.t < 3.4:
				b.next_throw = b.t + (0.18 if fast else 0.28); sfx("orb")
				ebul.append({"p": Vector2(ARENA + randf_range(16, W - 16), -8), "v": Vector2(0, 40), "k": "orb", "bn": 2})
			if b.t > 3.6:
				b.p.y = move_toward(b.p.y, GROUND, 400 * dt)
				if b.p.y >= GROUND:
					shake = 0.3; sfx("crash"); add_parts(b.p, 16, PAL.g, 90); next_attack()
	if b.st != "intro": b.p.x = clamp(b.p.x, ARENA + 24, ARENA + W - 24)
	if b.st != "intro" and Rect2(b.p.x - 13, b.p.y - 40, 26, 40).intersects(Rect2(pp.x - 12, pp.y - 40, 24, 36)): hurt_player()
func next_attack() -> void:
	var b := boss
	var opts := ["orbs", "dash", "rain"]
	opts.erase(b.st)
	b.st = opts[randi() % opts.size()]; b.t = 0.0; b.next_throw = 0.3; b.n = 6 if b.hp < b.max / 2 else 4
	if b.st == "dash": b.dir = -1 if b.p.x > ARENA + W / 2 else 1
	if randf() < 0.6: say("KELDARAH: " + TAUNTS[randi() % TAUNTS.size()])
func boss_defeated() -> void:
	bossdead_t = 0.01; ebul.clear(); sfx("explode"); shake = 0.6; flash = 1.0
	add_score(10000, boss.p + Vector2(0, -30))
	say("KELDARAH: NOOO! MY SHOULDER PADS!")
const REUNION := [[5.0, "WHAM!: CHUMPLEE!! YOU SAVED US!!"], [8.5, "CHUMPLEE: GROUP HUG! BRING IT IN, BOYS!"], [12.5, "WHAM!: WE THOUGHT WE'D BE STUCK IN THOSE BALLS FOREVER!"], [16.5, "CHUMPLEE: NOBODY KEL-BALLS MY FAVORITE BAND."], [20.5, "WHAM!: THIS CALLS FOR A VICTORY DANCE!!"], [25.5, "WHAM!: THANK YOU, CHUMPLEE. YOU'RE OUR BIGGEST FAN!"], [29.5, "CHUMPLEE: BIGGEST FAN? BUDDY, I'M EVERYBODY'S BIGGEST FAN. LOOK AT ME."], [33.5, "KELDARAH: ENJOY IT WHILE IT LASTS, CHUMPLEE!! MWAHAHA!"], [37.5, "CHUMPLEE: ...SHE'S GONNA BE A PROBLEM, ISN'T SHE."]]
const REUNION_END := 41.5
func update_bossdead(dt: float) -> void:
	var prev := bossdead_t
	bossdead_t += dt
	var t := bossdead_t
	var b := boss
	if t < 2.0 and randf() < 0.3:
		sfx("explode"); add_parts(b.p + Vector2(randf_range(-10, 10), randf_range(-24, 0)), 10, [PAL.p, PAL.Y, PAL.c][randi() % 3], 100)
	if t > 2.0 and prev <= 2.0: say("KELDARAH: THIS ISN'T OVER! SEE YOU IN LEVEL 2!")
	if t > 2.6 and t < 8.0: b.p.y -= 160 * dt; add_parts(b.p + Vector2(0, 2), 1, PAL.w, 30, 0.5, 3)
	if t > 4.5 and prev <= 4.5:
		sfx("powerup"); add_parts(Vector2(ARENA + W / 2, GROUND - 6), 30, PAL.w, 120)
		music.stream = snd["music_lc"]; music.play()
	for l in REUNION:
		if t > l[0] and prev <= l[0]:
			say(l[1]); taunt_t = 3.8
	# Chumplee walks over for the group hug
	var hug_x: float = ARENA + W / 2 - 38
	if t > 7.0 and t < 21.0:
		if abs(pp.x - hug_x) > 1: facing = 1 if hug_x > pp.x else -1
		pp.x = move_toward(pp.x, hug_x, 70 * dt)
	if t > 9.0 and t < 20.0 and randf() < 0.12: add_parts(Vector2(ARENA + W / 2 + randf_range(-30, 20), GROUND - 40), 1, PAL.p, 20, 1.0, 3)
	if t > 20.5 and t < 33.0 and randf() < 0.5:
		parts.append({"p": Vector2(ARENA + randf_range(0, W), -4), "v": Vector2(randf_range(-20, 20), randf_range(40, 90)), "l": 2.5, "c": [PAL.p, PAL.c, PAL.Y, PAL.G][randi() % 4], "s": 2.0})
	# Keldarah's hairspray-jet flyby tease
	if t > 33.0 and t < 37.5:
		b.p = Vector2(ARENA + W + 30 - (t - 33.0) * 110, 80 + sin(t * 3) * 8)
		add_parts(b.p + Vector2(12, 2), 1, PAL.w, 30, 0.5, 3)
	if t >= 37.5: b.p.y = -200
	pp.y = min(pp.y + 300 * dt, GROUND)
	update_parts(0)
	taunt_t -= dt
	if t > REUNION_END:
		score += lives * 5000; set_state("win")

# ---------------- cutscene ----------------
const CONCERT := 60.0
const SLOW := 1.35
const CUT_END := CONCERT + 17.0 * SLOW
const TYPE_CPS := 16.0
func cut_t() -> float:
	return st if st < CONCERT else 6.0 + (st - CONCERT) / SLOW
var cut_text := ""
func update_cut(dt: float) -> void:
	if enter_hit() and st > 0.3: end_cut(); return
	var conc := st < CONCERT
	var t := cut_t()
	if conc:
		# light show sparkles + air-guitar sparks
		if randf() < 0.25: parts.append({"p": Vector2(randf_range(200, 380), 0), "v": Vector2(randf_range(-15, 15), randf_range(30, 70)), "l": 2.0, "c": [PAL.p, PAL.c, PAL.Y, PAL.G][randi() % 4], "s": 1.0})
		if t > 34.0 and t < 40.0 and randf() < 0.5: add_parts(Vector2(92, 128), 2, PAL.Y, 70, 0.5, 2)
		if t > 55.0 and randf() < 0.6: parts.append({"p": Vector2(randf_range(0, W), -4), "v": Vector2(randf_range(-20, 20), randf_range(40, 90)), "l": 2.5, "c": [PAL.p, PAL.c, PAL.Y, PAL.G][randi() % 4], "s": 2.0})
		var cheers := [7.5, 12.0, 18.5, 22.5, 27.5, 33.0, 39.5, 44.0, 49.0, 54.0, 57.5]
		for c in cheers:
			if t >= c and not cut_flags.has(c): cut_flags[c] = true; sfx("select")
		return
	var ev := [[6.0, "glass"], [9.0, "orb"], [9.8, "orb"], [13.4, "jump"], [14.5, "wind"], [19.4, "crash"]]
	for e in ev:
		if t >= e[0] and not cut_flags.has(e[0]):
			cut_flags[e[0]] = true
			match e[1]:
				"glass": music.stop(); sfx("scratch"); sfx("glass"); shake = 0.6; flash = 1.0; parts.clear()
				"orb": sfx("orb"); flash = 0.5
				"jump": sfx("jump")
				"wind": music.stream = snd["wind"]; music.play()
				"crash": music.stop(); sfx("crash"); shake = 0.9; flash = 1.0; add_parts(Vector2(192, GROUND), 40, Color("#b8a890"), 150, 1.2, 3)
	if t > 6.0 and t < 6.6 and randf() < 0.9:
		parts.append({"p": Vector2(randf_range(300, 380), randf_range(20, 140)), "v": Vector2(randf_range(-160, -40), randf_range(-60, 40)), "l": 1.2, "c": Color(0.7, 0.95, 1.0, 0.9), "s": 2.0})
	if st >= CUT_END: end_cut()
func end_cut() -> void:
	music.stop(); parts.clear(); start_game()
const CONCERT_LINES := [[0.0, "PENTHOUSE SUITE, NEON CITY. 1985."], [4.5, "A PRIVATE WHAM! SHOW. AUDIENCE: ONE."], [9.5, "CHUMPLEE: BEST. PRIVATE. CONCERT. EVER!!"], [14.5, "GEORGE: HELLO NEON CITY! ER... CHUMPLEE!"], [19.5, "CHUMPLEE: WOOOO! I'M THE WHOLE CROWD!!"], [24.5, "ANDREW: THIS ONE'S FOR OUR #1 FAN!"], [29.0, "CHUMPLEE: I'M ALSO YOUR #2 THRU #500 FAN."], [34.0, "*A 9-MINUTE AIR GUITAR SOLO BEGINS*"], [40.0, "GEORGE: HE'S... ACTUALLY KINDA GOOD?"], [45.0, "CHUMPLEE: LIGHTERS UP! THIS IS A BALLAD!!"], [50.0, "ANDREW: ENCORE?! WE'VE DONE TWELVE!"], [55.0, "CHUMPLEE: ONE. MORE. SONG!!!"]]
const ACTION_LINES := [[6.0, "KELDARAH: SORRY BOYS... THE PARTY'S OVER!"], [8.8, "KELDARAH: KEL-BALL, GO!!"], [11.0, "KELDARAH: TOODLES, CHUMPLEE! MWAHAHA!"], [12.6, "CHUMPLEE: NOT ON MY WATCH!!"], [14.5, "CHUMPLEE: AAAAAAAAAAAAAAAAAH!!!"], [19.4, ""], [20.8, "CHUMPLEE: ...NAILED IT."]]
func cut_lines() -> String:
	var cur := [0.0, ""]
	if st < CONCERT:
		for l in CONCERT_LINES:
			if st >= l[0]: cur = l
	else:
		for l in ACTION_LINES:
			var rt: float = CONCERT + (l[0] - 6.0) * SLOW
			if st >= rt: cur = [rt, l[1]]
	var n := int((st - cur[0]) * TYPE_CPS)
	return cur[1].substr(0, n)
func draw_concert_bg(t: float) -> void:
	# extra light show: sweeping lasers + flashing floor
	var ph := int(t / 5.0)
	for k in 4:
		var col: Color = [PAL.p, PAL.c, PAL.Y, PAL.G][(k + ph) % 4]
		var a := sin(t * (1.2 + k * 0.3) + k) * 0.9
		draw_line(Vector2(300, 13), Vector2(300, 13) + Vector2(sin(a), cos(a)) * 220, Color(col, 0.35), 1)
	if t > 19.0:
		for i in 12:
			if hsh(i, int(t * 4)) < 40: draw_rect(Rect2(i * 32, 134, 32, 82), Color([PAL.p, PAL.c, PAL.Y][i % 3], 0.07))
	if int(t * 6) % 2 == 0:
		for k in 6: draw_rect(Rect2(300 + cos(t * 2 + k) * 70, 40 + sin(t * 3 + k * 2) * 30 + k * 10, 2, 2), PAL.w)
func draw_concert_chump(cp: Vector2, t: float, bob: float) -> void:
	var jump: float = abs(sin(t * 5)) * 8 if (t > 19.0 and t < 24.0) or t > 55.0 else 0.0
	var p := cp + Vector2(0, -bob * 2 - jump)
	spr("rock", p)
	if t > 34.0 and t < 45.0:
		# air guitar solo, kneeling shred
		draw_rect(Rect2(p.x - 6, p.y - 20, 22, 5), Color(1, 1, 1, 0.35))
		draw_line(p + Vector2(14, -18), p + Vector2(30, -28), Color(1, 1, 1, 0.35), 1)
	else:
		draw_rect(Rect2(p.x - 8, p.y - 20, 20, 6), Color(1, 1, 1, 0.3))  # invisible air guitar
	if t > 45.0 and t < 55.0:
		var hx := p + Vector2(-16, -44 + sin(t * 2) * 2)
		draw_rect(Rect2(hx.x, hx.y, 3, 6), PAL.r); draw_circle(hx + Vector2(1.5, -2), 2, PAL.Y if int(t * 8) % 2 else Color("#ff8a20"))
	if t > 19.0 and t < 29.0:
		# homemade fan sign
		draw_rect(Rect2(p.x + 14, p.y - 62, 50, 16), PAL.w); draw_rect(Rect2(p.x + 14, p.y - 62, 50, 16), PAL.r, false, 1)
		draw_line(p + Vector2(20, -46), p + Vector2(14, -30), PAL.d)
		txt("I<3WHAM", Vector2(p.x + 39, p.y - 51), PAL.r, 6, true)
	var cheers := [[7.5, "WOO!"], [12.0, "YEAH!!"], [18.5, "ENCORE!"], [22.5, "WOOOO!"], [27.5, "I LOVE YOU!!"], [33.0, "SHRED!"], [39.5, "YES!!"], [44.0, "WOO!"], [49.0, "MORE!!"], [54.0, "ONE MORE!"], [57.5, "WOOOOO!"]]
	for c in cheers:
		if t >= c[0] and t < c[0] + 1.6: txt(c[1], p + Vector2(-6, -46 - (t - c[0]) * 10), [PAL.Y, PAL.p, PAL.c][int(t * 6) % 3], 8)

# ---------------- drawing ----------------
func txt(s: String, p: Vector2, col := Color.WHITE, size := 8, center := false) -> void:
	var x := p.x
	if center: x -= font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x / 2
	draw_string(font, Vector2(round(x) + 1, p.y + 1), s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(0, 0, 0, col.a))
	draw_string(font, Vector2(round(x), p.y), s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)
func hsh(a: int, b: int) -> int: return abs((a * 73856093) ^ (b * 19349663)) % 100
func sky() -> void:
	var cols := [Color("#0a0420"), Color("#1a0638"), Color("#300a50"), Color("#561060"), Color("#80206a")]
	for i in 5: draw_rect(Rect2(0, i * 32, W, 32), cols[i])
	for i in 40: draw_rect(Rect2(hsh(i, 1) * 3.84, hsh(i, 7) * 0.9, 1, 1), Color(1, 1, 1, 0.6))
func city(scroll: float, ground: float) -> void:
	# far layer
	for i in 30:
		var bw := 30 + hsh(i, 2) % 25
		var bx := fposmod(i * 34 - scroll * 0.2, 34 * 30) - 40
		var bh := 60 + hsh(i, 3)
		draw_rect(Rect2(bx, ground - bh, bw, bh), Color("#1c0c34"))
		for wy in range(int(ground - bh) + 6, int(ground) - 4, 8):
			for wx in range(int(bx) + 4, int(bx + bw) - 4, 6):
				if hsh(wx + int(scroll * 0.2), wy) < 22: draw_rect(Rect2(wx, wy, 2, 3), Color("#ffd870") * Color(1, 1, 1, 0.6))
	# near layer with neon signs
	var signs := ["ARCADE", "VIDEO", "DISCO", "PIZZA", "RADICAL", "MALL"]
	for i in 24:
		var bx := fposmod(i * 90 - scroll * 0.5, 90 * 24) - 90
		var bh := 70 + hsh(i, 5) % 50
		draw_rect(Rect2(bx, ground - bh, 70, bh), Color("#120820"))
		draw_rect(Rect2(bx, ground - bh, 70, 2), Color("#3a1860"))
		for wy in range(int(ground - bh) + 8, int(ground) - 30, 12):
			for wx in [8, 24, 40, 56]:
				draw_rect(Rect2(bx + wx, wy, 6, 6), Color("#ffcc66") if hsh(i * 7 + wx, wy) < 35 else Color("#24123c"))
		var c: Color = [PAL.p, PAL.c, PAL.Y][i % 3]
		var s: String = signs[i % signs.size()]
		var a := 0.6 + 0.4 * float(int(st * 3 + i) % 5 != 0)
		draw_rect(Rect2(bx + 6, ground - 26, 58, 13), Color(0, 0, 0, 0.7))
		draw_rect(Rect2(bx + 6, ground - 26, 58, 13), Color(c, a), false, 1)
		txt(s, Vector2(bx + 35, ground - 16), Color(c, a), 8 if s.length() < 7 else 6, true)
func street() -> void:
	draw_rect(Rect2(0, GROUND, W, H - GROUND), Color("#1a1428"))
	draw_rect(Rect2(0, GROUND, W, 2), PAL.c)
	draw_rect(Rect2(0, GROUND + 12, W, H), Color("#24203a"))
	for i in 12:
		var x := fposmod(i * 40 - cam_x, 480) - 40
		draw_rect(Rect2(x, GROUND + 20, 20, 2), Color("#ffe020"))

func draw_orb(p: Vector2, r := 5.0) -> void:
	draw_circle(p, r + 1, PAL.k)
	draw_circle(p, r, PAL.w)
	var pts := PackedVector2Array()
	for i in 13: pts.append(p + Vector2(cos(PI + i * PI / 12), sin(PI + i * PI / 12)) * r)
	draw_colored_polygon(pts, PAL.r)
	draw_rect(Rect2(p.x - r, p.y - 0.5, r * 2, 1.5), PAL.k)
	draw_circle(p, 1.6, PAL.k); draw_circle(p, 1.0, PAL.w)

func draw_kel(p: Vector2, flip: bool, mod := Color.WHITE, cape_wave := 0.0) -> void:
	var s := -1.0 if flip else 1.0
	var cape := PackedVector2Array([p + Vector2(-12 * s, -22), p + Vector2(12 * s, -22), p + Vector2((28 + cape_wave * 2) * s, 1), p + Vector2((-6 + cape_wave) * s, 1)])
	draw_colored_polygon(cape, Color("#5a0a2a") * mod)
	draw_polyline(cape, Color("#c02050") * mod, 1)
	spr("kel", p, flip, mod)

func box(s: String) -> void:
	if s == "": return
	draw_rect(Rect2(8, H - 34, W - 16, 26), Color(0, 0, 0, 0.85))
	draw_rect(Rect2(8, H - 34, W - 16, 26), PAL.w, false, 1)
	txt(s, Vector2(16, H - 17), PAL.w)

func _draw() -> void:
	var sh := Vector2.ZERO
	if shake > 0: sh = Vector2(randf_range(-3, 3), randf_range(-3, 3)) * min(1.0, shake * 3)
	match state:
		"title": draw_title()
		"cut": draw_cut(sh)
		"card":
			draw_rect(Rect2(0, 0, W, H), PAL.k)
			txt("LEVEL 1", Vector2(W / 2, 90), PAL.p, 16, true)
			txt("NEON CITY STREETS", Vector2(W / 2, 115), PAL.c, 8, true)
			if int(st * 3) % 2 == 0: txt("GET READY, CHUMPLEE!", Vector2(W / 2, 140), PAL.Y, 8, true)
			txt(CONTROLS, Vector2(W / 2, 170), PAL.w, 6, true)
		"play", "cont": draw_play(sh)
		"win": draw_win()
		"over":
			draw_rect(Rect2(0, 0, W, H), PAL.k)
			txt("GAME OVER", Vector2(W / 2, 100), PAL.r, 16, true)
			txt("WHAM! REMAINS IN KEL-BALLS...", Vector2(W / 2, 125), PAL.w, 8, true)
	if flash > 0: draw_rect(Rect2(0, 0, W, H), Color(1, 1, 1, min(1.0, flash) * 0.8))
	# scanlines
	for y in range(0, H, 2): draw_rect(Rect2(0, y, W, 1), Color(0, 0, 0, 0.13))

func draw_title() -> void:
	sky()
	# synth sun
	var c := Vector2(W / 2, 112)
	for i in 30:
		var y := c.y - 50 + i * 3.4
		var half := sqrt(max(0.0, 50 * 50 - pow(y - c.y, 2)))
		var col := Color("#ffe040").lerp(Color("#ff2a90"), i / 30.0)
		if i > 14 and i % 3 == 0: continue
		draw_rect(Rect2(c.x - half, y, half * 2, 3.4), col)
	# grid floor
	draw_rect(Rect2(0, 132, W, H - 132), Color("#12002a"))
	for i in 9:
		var y := 132 + pow(fmod(i / 9.0 + st * 0.25, 1.0), 2) * (H - 132)
		draw_line(Vector2(0, y), Vector2(W, y), Color("#ff3fa8"), 1)
	for i in range(-12, 13):
		draw_line(Vector2(W / 2 + i * 8, 132), Vector2(W / 2 + i * 60, H), Color("#ff3fa8"), 1)
	draw_line(Vector2(0, 132), Vector2(W, 132), PAL.c, 1)
	txt("HI-SCORE %06d" % hiscore, Vector2(W / 2, 14), PAL.r, 8, true)
	txt("CHUMPLEE in", Vector2(W / 2, 36), PAL.c, 8, true)
	var t1 := "WAKE ME UP BEFORE"
	var t2 := "YOU GUN-GUN!"
	for k in 2:
		var off := Vector2(2, 2) if k == 0 else Vector2.ZERO
		var cc := Color("#5a0080") if k == 0 else PAL.Y
		var cc2 := Color("#5a0080") if k == 0 else Color("#ff3fa8")
		txt(t1, Vector2(W / 2, 58) + off, cc, 16, true)
		txt(t2, Vector2(W / 2, 80) + off, cc2, 16, true)
	# attract parade
	var px := fposmod(st * 60, W + 260) - 40
	spr("ch%d" % (int(st * 10) % 3), Vector2(px, 186))
	draw_rect(Rect2(px + 4, 167, 14, 4), PAL.g)
	spr("thug", Vector2(px - 44, 186)); spr("punk", Vector2(px - 84, 186))
	draw_kel(Vector2(px - 136, 186), false, Color.WHITE, sin(st * 8) * 3)
	if int(st * 2) % 2 == 0:
		txt("PRESS ENTER TO START", Vector2(W / 2, 156), PAL.w, 8, true)
	else:
		txt("INSERT COIN", Vector2(W / 2, 156), PAL.c, 8, true)
	txt(CONTROLS, Vector2(W / 2, 199), Color(0.6, 0.95, 1, 0.85), 6, true)
	txt("(C) 1985 LOMB ARCADE   CREDIT 1", Vector2(W / 2, 210), Color(1, 1, 1, 0.7), 6, true)

func penthouse(t: float, conc := false) -> void:
	draw_rect(Rect2(0, 0, W, H), Color("#0a0418"))
	# big windows with city
	draw_set_transform(Vector2(0, 0))
	for wi in 3:
		var wx := 20 + wi * 124
		draw_rect(Rect2(wx, 14, 110, 118), Color("#140830"))
		var broken := wi == 2 and not conc
		for i in 8:
			var bx := wx + 4 + i * 14
			var bh := 30 + hsh(i + wi * 9, 4) % 70
			draw_rect(Rect2(bx, 132 - bh, 12, bh), Color("#24104a"))
			for wy in range(132 - bh + 4, 128, 6):
				if hsh(bx, wy) < 30: draw_rect(Rect2(bx + 3, wy, 2, 2), Color("#ffd870"))
		if not broken:
			draw_rect(Rect2(wx, 14, 110, 118), Color(0.6, 0.8, 1, 0.08))
			draw_line(Vector2(wx + 10, 20), Vector2(wx + 30, 40), Color(1, 1, 1, 0.25))
		else:
			for k in 6:
				var a := Vector2(wx + hsh(k, 1) * 1.1, 14 + hsh(k, 2) * 1.18)
				draw_line(a, a + Vector2(10, 14), Color(0.8, 0.95, 1, 0.6))
			draw_rect(Rect2(wx, 14, 110, 4), Color(0.7, 0.9, 1, 0.5))
		draw_rect(Rect2(wx - 2, 12, 114, 122), Color("#6a4a8a"), false, 2)
	# floor + stage
	draw_rect(Rect2(0, 134, W, H - 134), Color("#2a1438"))
	for i in 24: draw_rect(Rect2(i * 16 + (8 if (i / 1) % 2 else 0), 134 + (i % 2) * 6, 8, 4), Color("#3a1c4c"))
	draw_rect(Rect2(220, 150, 150, 10), Color("#4a2060"))
	draw_rect(Rect2(220, 150, 150, 2), PAL.p)
	# stage lights
	if conc:
		for k in 3:
			var lx := 240 + k * 50
			var col: Color = [PAL.p, PAL.c, PAL.Y][(k + int(t * 2)) % 3]
			draw_colored_polygon(PackedVector2Array([Vector2(lx, 0), Vector2(lx + 4, 0), Vector2(lx + 24 + sin(t * 2 + k) * 20, 150), Vector2(lx - 20 + sin(t * 2 + k) * 20, 150)]), Color(col, 0.18))
	# disco ball
	draw_line(Vector2(300, 0), Vector2(300, 8), PAL.g)
	draw_circle(Vector2(300, 13), 5, PAL.e)
	if int(t * 6) % 2 == 0: draw_rect(Rect2(298, 11, 2, 2), PAL.w)

func draw_cut(sh: Vector2) -> void:
	var conc := st < CONCERT
	var t := cut_t()
	draw_set_transform(sh)
	if conc or t < 14.5:
		penthouse(t, conc)
		if conc: draw_concert_bg(t)
		var bob := float(int(t * 6) % 2)
		# Wham on stage
		var g_pos := Vector2(270, 150 - bob)
		var a_pos := Vector2(325, 150 - (1 - bob))
		if conc:
			var dn := int(t / 5.0) % 3
			if dn == 1: g_pos += Vector2(sin(t * 3) * 8, -abs(sin(t * 6)) * 5); a_pos += Vector2(-sin(t * 3) * 8, -abs(sin(t * 6 + 1.5)) * 5)
			elif dn == 2: g_pos.y -= abs(sin(t * 7)) * 7; a_pos.y -= abs(sin(t * 7)) * 7
		var captured_g := not conc and t >= 9.0
		var captured_a := not conc and t >= 9.8
		if not captured_g or (t < 9.3 and int(t * 20) % 2 == 0):
			spr("george", g_pos)
			draw_line(g_pos + Vector2(10, -26), g_pos + Vector2(14, -6), PAL.g); draw_circle(g_pos + Vector2(10, -26), 2.5, PAL.d)
		if not captured_a or (t < 10.1 and int(t * 20) % 2 == 0):
			spr("andrew", a_pos, true)
			draw_rect(Rect2(a_pos.x - 12, a_pos.y - 18, 18, 7), PAL.r)  # guitar
			draw_line(a_pos + Vector2(-12, -15), a_pos + Vector2(-26, -24), PAL.m, 1)
		if conc:
			for k in 4:
				var np := Vector2(250 + k * 30 + sin(t * 2 + k) * 6, 120 - fmod(t * 20 + k * 15, 60))
				txt("~" if k % 2 else "*", np, [PAL.p, PAL.c, PAL.Y, PAL.G][k], 8)
		# Keldarah
		var kp := Vector2(-100, -100)
		if not conc and t >= 6.0 and t < 13.0:
			var u: float = clamp((t - 6.0) / 0.5, 0, 1)
			kp = Vector2(lerp(400.0, 300.0, u), lerp(60.0, 150.0, u))
			if t > 11.2:
				var v: float = clamp((t - 11.2) / 0.8, 0, 1)
				kp = Vector2(lerp(300.0, 400.0, v), 150 - sin(v * PI) * 50)
			draw_kel(kp, true, Color.WHITE, sin(t * 10) * 3)
		# orbs
		for k in 2:
			var tt: float = [9.0, 9.8][k]
			var target: Vector2 = [g_pos, a_pos][k] + Vector2(0, -4)
			if not conc and t >= tt - 0.4 and t < 11.2:
				var u: float = clamp((t - (tt - 0.4)) / 0.4, 0, 1)
				var p := Vector2(300, 135).lerp(target, u) + Vector2(0, -sin(u * PI) * 20)
				if u >= 1: p = target + Vector2(0, -sin(t * 18) * 1.5)
				draw_orb(p)
			if not conc and t >= 11.2 and t < 12.0: draw_orb(kp + Vector2(-10 + k * 20, -50))
		# Chumplee
		var cp := Vector2(90, 150)
		if conc:
			draw_concert_chump(cp, t, bob)
		elif t < 12.6:
			spr("ch0", cp, false)
			if t > 6.3: txt("?!", cp + Vector2(-8, -42), PAL.r)
		else:
			var u: float = clamp((t - 12.6) / 1.4, 0, 1)
			var p := Vector2(lerp(90.0, 400.0, u), 150 - (sin(clamp((u - 0.6) / 0.4, 0, 1) * PI) * 40 if u > 0.6 else 0.0))
			spr("chj" if u > 0.6 else "ch%d" % (int(t * 10) % 3), p)
	elif t < 19.4:
		# falling
		var u := t - 14.5
		draw_rect(Rect2(0, 0, W, H), Color("#120628"))
		for i in 30: draw_rect(Rect2(hsh(i, 3) * 3.84, fposmod(hsh(i, 9) * 2.2 - u * 30, H), 1, 1), PAL.w)
		var sc := u * 520.0
		for side in 2:
			var bx := 40 if side == 0 else 280
			draw_rect(Rect2(bx, 0, 64, H), Color("#1e1038"))
			draw_rect(Rect2(bx + (64 if side == 0 else 0), 0, 2, H), PAL.p if side == 0 else PAL.c)
			for r in range(-1, 12):
				var y := fposmod(r * 20 - sc, 260) - 30
				for c in 4:
					draw_rect(Rect2(bx + 6 + c * 15, y, 9, 12), Color("#ffcc66") if hsh(r + int(sc / 260) * 13, c + side) < 40 else Color("#2c1850"))
		for i in 18:
			var x := hsh(i, 5) * 3.84
			var y := fposmod(hsh(i, 6) * 3 - u * 900 * (1 + i % 3 * 0.3), H + 60) - 30
			draw_line(Vector2(x, y), Vector2(x, y + 24), Color(1, 1, 1, 0.5))
		# Keldarah below gliding away
		if u < 3.0:
			draw_kel(Vector2(200 + u * 70 + sin(u * 4) * 8, 190 - u * 10), true, Color.WHITE, sin(u * 12) * 4)
			if u < 2.0: txt("HA HA HA!", Vector2(210 + u * 70, 150), PAL.p, 8)
		var cp := Vector2(180 + sin(u * 7) * 10, 90 + sin(u * 3) * 6)
		spr("fall", cp, int(u * 8) % 2 == 0)
	else:
		# impact on street
		var u := t - 19.4
		sky(); city(0, GROUND); street()
		var cp := Vector2(192, GROUND)
		if u < 0.0: cp.y = -20
		draw_colored_polygon(PackedVector2Array([Vector2(160, GROUND), Vector2(170, GROUND + 6), Vector2(214, GROUND + 6), Vector2(224, GROUND), Vector2(210, GROUND - 2), Vector2(174, GROUND - 2)]), Color("#0a0610"))
		for k in 6:
			draw_line(Vector2(192, GROUND + 2), Vector2(192 + (k - 2.5) * 22, GROUND + 4 + (k % 2) * 6), PAL.k, 1)
		if u < 1.2:
			spr("fall", cp + Vector2(0, 6), false, Color(1, 1, 1))
		else:
			spr("ch0", cp + Vector2(0, -2))
		if u < 1.6:
			var sc: float = 1.0 + max(0.0, 0.4 - u)
			txt("CRASH!!", Vector2(W / 2, 80), PAL.Y if int(u * 10) % 2 == 0 else PAL.r, int(24 * sc / 8) * 8, true)
	draw_set_transform(Vector2.ZERO)
	for q in parts: draw_rect(Rect2(q.p.x + sh.x, q.p.y + sh.y, q.s, q.s), Color(q.c, min(1.0, q.l * 2)))
	box(cut_lines())
	txt("ENTER: SKIP", Vector2(W - 72, 10), Color(1, 1, 1, 0.5), 6)

func draw_play(sh: Vector2) -> void:
	sky()
	city(cam_x, GROUND)
	draw_set_transform(Vector2(-round(cam_x), 0) + sh)
	# boss arena backdrop
	draw_rect(Rect2(ARENA, GROUND - 4, W, 4), Color(PAL.p, 0.4))
	draw_rect(Rect2(LEVEL_END - 2, 0, 6, GROUND), PAL.p)
	draw_set_transform(sh)
	street()
	draw_set_transform(Vector2(-round(cam_x), 0) + sh)
	for r in platforms:
		draw_rect(r, Color("#5a1a7a")); draw_rect(Rect2(r.position, Vector2(r.size.x, 2)), PAL.c)
		draw_line(r.position + Vector2(4, 6), Vector2(r.position.x + 4, GROUND), Color("#3a1050"))
		draw_line(Vector2(r.end.x - 4, r.position.y + 6), Vector2(r.end.x - 4, GROUND), Color("#3a1050"))
	for pk in pickups:
		var p: Vector2 = pk.p + Vector2(0, -4 + sin(st * 4) * 2)
		if pk.k == "tape":
			draw_rect(Rect2(p.x - 7, p.y - 5, 14, 9), PAL.k); draw_rect(Rect2(p.x - 6, p.y - 4, 12, 7), PAL.p)
			draw_rect(Rect2(p.x - 4, p.y - 2, 8, 3), PAL.w); draw_rect(Rect2(p.x - 3, p.y - 1, 2, 1), PAL.k); draw_rect(Rect2(p.x + 1, p.y - 1, 2, 1), PAL.k)
		else:
			draw_circle(p + Vector2(-2, -1), 2.5, PAL.r); draw_circle(p + Vector2(2, -1), 2.5, PAL.r)
			draw_colored_polygon(PackedVector2Array([p + Vector2(-4.5, 0), p + Vector2(4.5, 0), p + Vector2(0, 5)]), PAL.r)
	for e in enemies:
		var m := Color(10, 10, 10) if e.fl > 0 else Color.WHITE
		var fl: bool = pp.x > e.p.x
		match e.t:
			"thug":
				spr("thug", e.p + Vector2(0, int(st * 6) % 2), fl, m)
				draw_rect(Rect2(e.p.x + (6 if fl else -16), e.p.y - 17, 10, 3), PAL.d)
			"punk":
				spr("punk", e.p, false, m); draw_line(e.p + Vector2(12, -12), e.p + Vector2(26, -12), Color(1, 1, 1, 0.4))
			"boom": spr("boom", e.p, false, m)
	if boss_active and not boss.is_empty():
		var m := Color(10, 10, 10) if boss.fl > 0 else Color.WHITE
		if bossdead_t > 0 and bossdead_t < 2.6: m = Color(1, 0.5, 0.5) if int(bossdead_t * 12) % 2 else Color.WHITE
		if boss.st == "dash" and boss.t < 0.7 and int(boss.t * 14) % 2 == 0: m = Color(2, 0.6, 0.6)
		if boss.st == "rain" and boss.p.y < GROUND - 2:
			draw_line(boss.p + Vector2(-4, 1), boss.p + Vector2(-6, 12), PAL.w); draw_line(boss.p + Vector2(4, 1), boss.p + Vector2(6, 12), PAL.w)
		var kp: Vector2 = boss.p
		if boss.st == "dash" and boss.t < 0.7: kp.x += sin(boss.t * 60) * 1.5
		draw_kel(kp, pp.x < boss.p.x, m, sin(st * 9) * 3)
		if bossdead_t > 4.5:
			var bt := bossdead_t
			var bob := float(int(st * 5) % 2)
			var dance := bt > 20.5 and bt < 33.0
			var jy: float = abs(sin(st * 8)) * 8 if dance else 0.0
			var jy2: float = abs(sin(st * 8 + 1.6)) * 8 if dance else 0.0
			var gx := ARENA + W / 2 - 14 + (sin(st * 4) * 10 if dance else 0.0)
			var ax := ARENA + W / 2 + 14 - (sin(st * 4) * 10 if dance else 0.0)
			if dance:
				for k in 3:
					var lx := ARENA + 60 + k * 130
					var col: Color = [PAL.p, PAL.c, PAL.Y][(k + int(st * 3)) % 3]
					draw_colored_polygon(PackedVector2Array([Vector2(lx, 0), Vector2(lx + 4, 0), Vector2(lx + 30 + sin(st * 2 + k) * 40, GROUND), Vector2(lx - 26 + sin(st * 2 + k) * 40, GROUND)]), Color(col, 0.16))
			spr("george", Vector2(gx, GROUND - bob - jy), dance and int(st * 2) % 2 == 0)
			spr("andrew", Vector2(ax, GROUND - (1 - bob) - jy2), not (dance and int(st * 2) % 2 == 0))
			if bt > 9.0 and bt < 20.0:
				for k in 3:
					var hp2 := Vector2(ARENA + W / 2 - 24 + k * 16, GROUND - 52 - fmod(st * 14 + k * 9, 24))
					draw_circle(hp2 + Vector2(-2, 0), 2.5, PAL.r); draw_circle(hp2 + Vector2(2, 0), 2.5, PAL.r)
					draw_colored_polygon(PackedVector2Array([hp2 + Vector2(-4.5, 1), hp2 + Vector2(4.5, 1), hp2 + Vector2(0, 6)]), PAL.r)
		elif bossdead_t == 0 or bossdead_t < 4.5:
			draw_orb(Vector2(ARENA + W / 2 - 14, GROUND - 6 - abs(sin(st * 3)) * 3)); draw_orb(Vector2(ARENA + W / 2 + 14, GROUND - 6 - abs(sin(st * 3 + 1)) * 3))
	# player
	if state == "play" and bossdead_t > 20.5 and bossdead_t < 33.0:
		var bob2 := float(int(st * 6) % 2)
		spr("rock", Vector2(pp.x, pp.y - bob2 * 3 - abs(sin(st * 8 + 0.8)) * 6), int(st * 2) % 2 == 1)
	elif state == "play" and (inv <= 0 or int(st * 16) % 2 == 0):
		var n := "chj" if not on_ground else ("ch%d" % (int(run_anim) % 3) if abs(pv.x) > 0 else "ch0")
		var fl := facing < 0
		spr(n, pp, fl)
		var up: bool = inp().u if mode == "" else false
		if up and abs(pv.x) < 1: draw_rect(Rect2(pp.x - 1, pp.y - 46, 4, 14), PAL.g)
		else: draw_rect(Rect2(pp.x + (4 if not fl else -18), pp.y - 19, 14, 4), PAL.g); draw_rect(Rect2(pp.x + (16 if not fl else -20), pp.y - 19, 4, 3), PAL.c)
	for b in pbul:
		draw_rect(Rect2(b.p.x - 2, b.p.y - 1, 4, 2), PAL.Y); draw_rect(Rect2(b.p.x - 1, b.p.y - 1, 2, 2), PAL.w)
	for b in ebul:
		match b.k:
			"orb": draw_orb(b.p, 4)
			"note": txt("~", b.p + Vector2(-4, 4), PAL.c, 8)
			_: draw_circle(b.p, 2, PAL.r)
	for q in parts: draw_rect(Rect2(q.p.x, q.p.y, q.s, q.s), Color(q.c, min(1.0, q.l * 2)))
	for f in floats: txt(f.t, f.p, Color(1, 1, 0.5, min(1.0, f.l * 2)), 6, true)
	draw_set_transform(Vector2.ZERO)
	# HUD
	txt("1UP %06d" % score, Vector2(6, 12), PAL.w)
	txt("HI %06d" % max(hiscore, score), Vector2(W / 2, 12), PAL.r, 8, true)
	txt("x%d" % lives, Vector2(W - 34, 12), PAL.Y)
	spr("ch0", Vector2(W - 44, 16), false, Color.WHITE, 1.0)
	for i in 5:
		draw_rect(Rect2(6 + i * 9, 18, 7, 6), PAL.k)
		draw_rect(Rect2(7 + i * 9, 19, 5, 4), PAL.r if i < hp else Color("#402030"))
	var cw := font.get_string_size(CONTROLS, HORIZONTAL_ALIGNMENT_LEFT, -1, 6).x
	txt(CONTROLS, Vector2(W - 4 - cw, H - 4), Color(1, 1, 1, 0.45), 6)
	if spread > 0: txt("SPREAD %d" % int(spread), Vector2(60, 24), PAL.p, 6)
	if not boss_active and int(st * 2) % 2 == 0 and st < 4: txt("GO! >>", Vector2(W - 60, 100), PAL.Y)
	if boss_active and not boss.is_empty() and bossdead_t == 0:
		txt("KELDARAH", Vector2(W / 2, 34), PAL.p, 6, true)
		draw_rect(Rect2(W / 2 - 61, 37, 122, 6), PAL.w)
		draw_rect(Rect2(W / 2 - 60, 38, 120, 4), PAL.k)
		draw_rect(Rect2(W / 2 - 60, 38, 120.0 * boss.hp / boss.max, 4), PAL.p)
	if taunt_t > 0 and taunt != "":
		var lines: Array = wrap_txt(taunt, 34)
		var bh: int = 6 + lines.size() * 9
		draw_rect(Rect2(W / 2 - 110, 48, 220, bh), Color(1, 1, 1, 0.95)); draw_rect(Rect2(W / 2 - 110, 48, 220, bh), PAL.p, false, 1)
		for i in lines.size(): txt(lines[i], Vector2(W / 2, 57 + i * 9), PAL.v if taunt.begins_with("K") else PAL.b, 6, true)
	if state == "cont":
		draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 0.7))
		txt("CONTINUE?", Vector2(W / 2, 90), PAL.Y, 16, true)
		txt(str(int(max(0.0, cont_t))), Vector2(W / 2, 125), PAL.r, 24, true)
		txt("PRESS ENTER", Vector2(W / 2, 150), PAL.w, 8, true)

func wrap_txt(s: String, n: int) -> Array:
	var out := []; var cur := ""
	for w in s.split(" "):
		if (cur + " " + w).length() > n and cur != "": out.append(cur); cur = w
		else: cur = w if cur == "" else cur + " " + w
	out.append(cur); return out

func draw_win() -> void:
	sky(); city(st * 20, GROUND); 
	draw_rect(Rect2(0, GROUND, W, H), Color("#1a1428")); draw_rect(Rect2(0, GROUND, W, 2), PAL.c)
	txt("YOU SAVED WHAM!", Vector2(W / 2, 40), PAL.Y, 16, true)
	txt("SCORE %06d" % score, Vector2(W / 2, 64), PAL.w, 8, true)
	if score >= hiscore: txt("NEW HIGH SCORE!", Vector2(W / 2, 78), PAL.p, 8, true)
	var bob := float(int(st * 5) % 2)
	spr("george", Vector2(160, GROUND - bob)); spr("rock", Vector2(192, GROUND - (1 - bob))); spr("andrew", Vector2(224, GROUND - bob), true)
	for k in 6: txt("*", Vector2(130 + k * 25, 140 - fmod(st * 30 + k * 13, 40)), [PAL.p, PAL.c, PAL.Y][k % 3])
	txt("BUT KELDARAH ESCAPED...", Vector2(W / 2, 100), PAL.c, 8, true)
	txt("TO BE CONTINUED IN LEVEL 2!", Vector2(W / 2, 114), PAL.r, 8, true)
	if st > 2 and int(st * 2) % 2 == 0: txt("PRESS ENTER", Vector2(W / 2, 205), PAL.w, 8, true)

# ---------------- automated tests (--test=dash | --test=powerup) ----------------
var tst := {}
func start_test() -> void:
	start_game()
	tst = {"t": 0.0, "dashes": 0, "fail": "", "last_x": 0.0, "still": 0.0, "prev_st": ""}
	if mode == "test_powerup":
		pp.x = ARENA + 40; cam_x = ARENA - 100; spread = 4.0; tst.spread_before = 0.0
	else:
		pp.x = ARENA + 40; cam_x = ARENA; start_boss(); boss.hp = 1000000; boss.max = 2000000
func run_test(dt: float) -> void:
	tst.t += dt
	if mode == "test_powerup":
		if not boss_active:
			pp.x = ARENA + 70; tst.spread_before = spread
			return
		if not tst.has("checked"):
			tst.checked = true
			print("TEST powerup: spread at boss start=", snapped(tst.spread_before, 0.01), " after transition=", snapped(spread, 0.01))
		if boss.st == "intro":
			if spread <= 0: tst.fail = "spread lost during boss intro"
		elif not tst.has("done"):
			tst.done = true
			if spread <= 0: tst.fail = "spread gone when boss fight began"
			elif tst.spread_before - spread > 0.1: tst.fail = "timer drained during transition (%.2f -> %.2f)" % [tst.spread_before, spread]
			print("TEST powerup: spread when first attack starts=", snapped(spread, 0.01))
			print("TEST RESULT powerup: ", "PASS" if tst.fail == "" else "FAIL " + tst.fail); get_tree().quit()
		if tst.fail != "": print("TEST RESULT powerup: FAIL ", tst.fail); get_tree().quit()
		return
	# dash test: force every attack to be a dash
	var b := boss
	if b.st != "intro" and b.st != "dash": b.st = "dash"; b.t = 0.0; b.dir = -1 if b.p.x > ARENA + W / 2 else 1
	if b.st == "dash" and (tst.prev_st != "dash" or b.t < tst.get("prev_t", 0.0)):
		tst.dashes += 1; tst.dash_t = 0.0
		var stx: float = b.p.x - ARENA
		tst.log = tst.get("log", "") + " %d@%d" % [int(stx), b.dir]
	if b.st == "dash":
		tst.dash_t += dt
		if tst.dash_t > 4.0: tst.fail = "dash never finished (stuck) at x=%.1f dir=%d" % [b.p.x - ARENA, b.dir]
	if b.p.x < ARENA + 23.9 or b.p.x > ARENA + W - 23.9: tst.fail = "left arena x=%.1f" % (b.p.x - ARENA)
	tst.prev_st = b.st; tst.prev_t = b.t
	pp.x = ARENA + randf_range(20, W - 20)
	if tst.fail != "" or tst.dashes >= 30:
		print("TEST RESULT dash: ", "PASS" if tst.fail == "" else "FAIL " + tst.fail, " dashes=", tst.dashes, " starts(x@dir):", tst.get("log", ""), " t=", snapped(tst.t, 0.1)); get_tree().quit()

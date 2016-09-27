package enemies;

import kala.behaviors.display.SpriteAnimation;
import kala.math.Random;
import kala.util.pool.Pool;
import kha.FastFloat;
import player.Player;
import states.PlayState;

class EnemyC extends Enemy {

	#if (cap_30 && !debug)
	static inline var baseMaxHSpeed = 3;
	static inline var baseFlapPower = 6;
	static inline var baseVAccel = 0.5;
	static inline var baseFlipSpeed = 0.2;
	static inline var attackSpeed = 16;
	#else
	static inline var baseMaxHSpeed = 1.5;
	static inline var baseFlapPower = 3;
	static inline var baseVAccel = 0.125;
	static inline var baseFlipSpeed = 0.1;
	static inline var attackSpeed = 8;
	#end
	
	static var pool:Pool<EnemyC> = new Pool<EnemyC>(function() {
		var enemy = new EnemyC();
		PlayState.instance.enemyGroup.add(enemy);
		return enemy;
	});
	
	public static inline function create(size:Int, x:FastFloat, y:FastFloat):Void {
		PlayState.instance.onScreenEnemyCount++;
		
		var enemy = pool.get();
		enemy.revive();
		enemy.size = size;
		enemy.setXY(x, y);
	}
	
	public static inline function createRandomPos(size):Void {
		switch(Random.int(0, 2)) {
			case 0: create(size, -120, Random.int(0, 300));
			case 1: create(size, G.width + 120, Random.int(0, 300));
			case 2: create(size, Random.int(60, G.width - 60), -120);
		}
	}
	
	//
	
	var animation:SpriteAnimation;
	
	var size(default, set):Int;
	var baseScale:FastFloat;
	
	var maxHSpeed:FastFloat;
	var hspeed:FastFloat;
	var vspeed:FastFloat = 5;
	var vaccel:FastFloat;
	var hspeedAlarm:Int;
	var flapPower:FastFloat;
	var flapped:Bool;
	var vline:FastFloat;
	var vlineAlarm:Int;
	
	var flipSpeed:FastFloat;
	
	var targeting:Bool;
	var attackAlarm:Int;
	
	public function new() {
		super();
		
		sprite.loadSpriteData(R.enemyC, 0).animation.play();
		animation = sprite.animation;
		
		setOrigin(halfWidth = sprite.width / 2, (halfHeight = sprite.height / 2) - 25);
		addCircleMask(halfWidth, position.oy + 3, 40);
		
		hpText.setXY(halfWidth - 2, scale.oy + 2);
		hpText.size = 40;
		
		initDeathEffect();
		player = PlayState.instance.player;
		isSubEnemy = false;
	}
	
	override public function kill():Void {
		gemDropQuantity = Std.int(size * 3);
		super.kill();
	}
	
	override public function revive():Void {
		super.revive();
		targeting = bodyAtkOn = false;
		flapped = false;
		scale.y = 1;
		endAttacking();
	}
	
	override function updateAlive(elapsed:FastFloat):Void {
		super.updateAlive(elapsed);
		
		if (bodyAtkOn) {
			if (scale.y > -baseScale) scale.y -= flipSpeed * elapsed;
			else {
				if (scale.y < -baseScale) scale.y = -baseScale;
				animation.frame = 5;
				animation.delay = -1;
				y += attackSpeed * elapsed;
				if (y > G.height - 70) {
					endAttacking();
					#if (cap_30 && !debug)
					animation.delay = 1;
					vspeed = -8;
					#else
					animation.delay = 2;
					vspeed = -4;
					#end
				}
			}
		} else if (targeting) {
			bodyAtkOn = true;
			
			if (x - player.x > 15) {
				bodyAtkOn = false;
				x -= maxHSpeed * elapsed;
			} else if (x - player.x < -15) {
				bodyAtkOn = false;
				x += maxHSpeed * elapsed;
			}
	
			if (y > 100) {
				bodyAtkOn = false;
				vline = -100;
			}
		} else {
			if (scale.y < baseScale) scale.y += flipSpeed;
			else if (scale.y > baseScale) scale.y = baseScale;
			
			if (attackAlarm > 0) attackAlarm--;
			else targeting = true;
			
			if (hspeedAlarm > 0) hspeedAlarm--;
			else randomHSpeed();
			
			if (vlineAlarm > 0) vlineAlarm--;
			else randomVLine();
		
			if ((hspeed < 0 && x < mask.radius) || (hspeed > 0 && x > G.width - mask.radius)) {
				hspeed = -hspeed;
			}
			
			x += hspeed * elapsed;
		}
		
		if (scale.y > 0) {
			if (animation.frame == 0 || animation.frame == 3) {
				if (y < vline + 25) animation.delay = -1;
				#if (cap_30 && !debug)
				else if (y < vline + 100) animation.delay = Random.int(4, 8);
				else if (y > vline + 200) animation.delay = Random.int(2, 8);
				else if (y > vline + 250) animation.delay = 2;
				#else
				else if (y < vline + 100) animation.delay = Random.int(8, 16);
				else if (y > vline + 200) animation.delay = Random.int(4, 16);
				else if (y > vline + 250) animation.delay = 4;
				#end
			}
			
			if (animation.frame == 2 || animation.frame == 5) {
				if (!flapped) G.sfxGroup.play(R.sounds.flap, size / 5);
				
				if (!flapped) {
					vspeed = -flapPower;
					flapped = true;
				}
			} else {
				flapped = false;
			}
			
			y += vspeed * baseScale * elapsed;
			vspeed += vaccel * elapsed;
		}
	}
	
	override function put():Void {
		super.put();
		pool.putUnsafe(this);
	}
	
	inline function randomHSpeed():Void {
		if (x < G.halfWidth) {
			if (Random.bool(80)) hspeed = Random.float(0, maxHSpeed);
			else hspeed = Random.float(-maxHSpeed, 0);
		} else {
			if (Random.bool(80)) hspeed = Random.float(-maxHSpeed, 0);
			else hspeed = Random.float(0, maxHSpeed);
		}
		
		#if (cap_30 && !debug)
		hspeedAlarm = Random.int(120, 240);
		#else
		hspeedAlarm = Random.int(240, 480);
		#end
	}
	
	inline function randomVLine():Void {
		vline = Random.int(0, 100);
		#if (cap_30 && !debug)
		vlineAlarm = Random.int(100, 200);
		#else
		vlineAlarm = Random.int(200, 400);
		#end
	}
	
	inline function endAttacking():Void {
		targeting = bodyAtkOn = false;
		#if (cap_30 && !debug)
		attackAlarm = Random.int(300, 600);
		#else
		attackAlarm = Random.int(600, 1200);
		#end
		animation.delay = 0;
		randomVLine();
	}
	
	inline function set_size(value:Int):Int {
		baseScale = value / 4 + 0.25;
		scale.setXY(baseScale, baseScale);
		mask.radius = 40 * baseScale;
		
		maxHSpeed = baseMaxHSpeed * baseScale;
		randomHSpeed();
		
		flapPower = baseFlapPower * baseScale;
		vaccel = baseVAccel * baseScale;
		
		flipSpeed = baseFlipSpeed * baseScale;
		
		set_hp(switch(value) {
			case 1: 50;
			case 2: 100;
			case 3: 150;
			default: 0;
		});
		
		return size = value;
	}
	
}
package enemies;

import kala.DrawingData;
import kala.util.pool.Pool;
import kha.FastFloat;
import states.PlayState;

class EnemyA extends Enemy {

	#if (cap_30 && !debug)
	static inline var baseHSpeed = 2;
	static inline var bouncingSpeed = -12;
	static inline var vaccel = 0.2;
	static inline var elasticity = 0.02;
	#else
	static inline var baseHSpeed = 1;
	static inline var bouncingSpeed = -6;
	static inline var vaccel = 0.05;
	static inline var elasticity = 0.01;
	#end
	
	static var pool:Pool<EnemyA> = new Pool<EnemyA>(function() {
		var enemy = new EnemyA();
		PlayState.instance.enemyGroup.add(enemy);
		return enemy;
	});
	
	public static inline function create(size:Int, x:FastFloat, y:FastFloat):EnemyA {
		var enemy = pool.get();
		enemy.revive();
		enemy.size = size;
		enemy.setXY(x, y);
		return enemy;
	}
	
	//
	
	var size(default, set):Int;
	var baseScale:FastFloat;
	var baseRadius:FastFloat;

	var hspeed:FastFloat;
	var vspeed:FastFloat;
	
	var splitting:Bool;
	var originY:FastFloat;
	
	public function new() {
		super();
		sprite.loadSpriteData(R.enemyA);
		addCircleMask(
			halfWidth = scale.ox = position.ox = sprite.width / 2,
			halfHeight = sprite.height / 2,
			baseRadius = (sprite.height - 90) / 2
		);
		initDeathEffect();
	}
	
	override public function revive():Void {
		super.revive();
		vspeed = -3;
		splitting = false;
	}
	
	override public function kill():Void {
		if (size > 1) {
			splitting = true;
			baseScale = (size - 1) / 4 + 0.25;
			originY = (sprite.height - 90) * baseScale;
			hspeed = 0;
		} else {
			dropGems(5, 0, (-position.oy + halfHeight) * baseScale);
			super.kill();
		}
		
	}
	
	override function put():Void {
		pool.putUnsafe(this);
	}
	
	override function updateAlive(elapsed:FastFloat):Void {
		if (splitting) {
			#if (cap_30 && !debug)
			if (scale.oy > originY) position.oy = scale.oy -= 4;
			if (scale.y > baseScale) scale.y -= 0.02;
			if (scale.x > baseScale) scale.x -= 0.02;
			#else
			if (scale.oy > originY) position.oy = scale.oy -= 2;
			if (scale.y > baseScale) scale.y -= 0.01;
			if (scale.x > baseScale) scale.x -= 0.01;
			#end
			else {
				size--;
				splitting = false;
				var enemy = create(size, x, y);
				enemy.hspeed *= -1;
				enemy.vspeed = vspeed;
				enemy.scale.y = scale.y;
			}
			
			return;
		}
		
		if ((hspeed < 0 && x < mask.radius) || (hspeed > 0 && x > G.width - mask.radius)) {
			hspeed = -hspeed;
		}
		
		if (y > 400 && vspeed > 0) {
			scale.y *= 0.8;
			vspeed = bouncingSpeed;
		} else {
			if (scale.y < baseScale) scale.y += elasticity * elapsed;
		}

		x += hspeed * scale.x * elapsed;
		y += vspeed * scale.y * elapsed;
		
		vspeed += vaccel * elapsed;
		
		hpText.setXY(halfWidth, halfHeight);
	}
	
	inline function set_size(value:Int):Int {
		if (splitting) {
			position.oy = scale.oy = originY;
		} else {
			baseScale = value / 4 + 0.25;
			position.oy = scale.oy = (sprite.height - 90) * baseScale;
		}
		
		scale.setXY(baseScale, baseScale);
		mask.radius = baseRadius * baseScale;
		
		hspeed = baseHSpeed * baseScale + baseHSpeed;
		
		set_hp(switch(value) {
			case 1: 25;
			case 2: 50;
			case 3: 100;
			default: 0;
		});
		
		return size = value;
	}
	
}
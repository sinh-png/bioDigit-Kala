package enemies;

import enemies.EnemyD.Child;
import kala.behaviors.motion.VelocityMotion;
import kala.behaviors.tween.Ease;
import kala.math.Mathf;
import kala.math.Position;
import kala.math.Random;
import kala.objects.group.Group;
import kala.util.pool.Pool;
import kha.FastFloat;
import player.Player;
import states.PlayState;

class EnemyD extends Enemy {

	public static var childGroup:Group<Child> = new Group<Child>(false, function() {
		var child = new Child();
		child.revive();
		return child;
	});
	
	//

	static var pool:Pool<EnemyD> = new Pool<EnemyD>(function() {
		var enemy = new EnemyD();
		PlayState.instance.enemyGroup.add(enemy);
		return enemy;
	});
	
	public static inline function create(x:FastFloat, y:FastFloat):Void {
		var enemy = pool.get();
		enemy.revive();
		enemy.setXY(x, y);
		enemy.hp = 300;
		enemy.moveRandom(function() {
			for (i in 0...6) {
				enemy.createChild();
			}
		});
	}
	
	public function new() {
		super();
		
		#if (cap_30 && !debug)
		sprite.loadSpriteData(R.enemyD, 5).animation.play();
		#else
		sprite.loadSpriteData(R.enemyD, 10).animation.play();
		#end
		sprite.setOrigin(68, 64);
		
		hpText.size = 45;
		
		addCircleMask(0, 0, 50);
		
		halfWidth = sprite.width / 2;
		halfHeight = sprite.height / 2;
		
		tween.get()
			.startLoop()
				#if (cap_30 && !debug)
				.tween(sprite, { y: 80 }, 60, Ease.sineInOut)
				.tween(sprite, { y: 0 }, 60, Ease.sineInOut)
				#else
				.tween(sprite, { y: 80 }, 120, Ease.sineInOut)
				.tween(sprite, { y: 0 }, 120, Ease.sineInOut)
				#end
			.endLoop()
		.start();
		
		initDeathEffect();
	}
	
	override public function kill():Void {
		super.kill();
		dropGems(9, 0, 0);
	}
	
	override function updateAlive(elapsed:FastFloat):Void {
		super.updateAlive(elapsed);
		
		hpText.y = sprite.y;
		mask.position.y = sprite.y + 2;
	}
	
	inline function createChild():Void {
		var child = childGroup.createAlive();
		child.setXY(x, y + sprite.y);
		child.motion.velocity.setAngleSpeed(
			Random.int(270 - 40, 270 + 40),
			Random.float(0, Child.startSpeedMax)
		);
		child.leftTurning = Random.bool();
		child.turningDelay = Random.int(Child.turnDelayMin, Child.turnDelayMax);
		child.hp = 9;
	}
	
}

class Child extends Enemy {
	
	#if (cap_30 && !debug)
	public static inline var startSpeedMax = 1;
	public static inline var turnDelayMin = 30;
	public static inline var turnDelayMax = 45;
	static inline var accel = 0.1;
	static inline var turnSpeed = 8;
	#else
	public static inline var startSpeedMax = 0.5;
	public static inline var turnDelayMin = 60;
	public static inline var turnDelayMax = 90;
	static inline var accel = 0.025;
	static inline var turnSpeed = 4;
	#end
	
	public var motion:VelocityMotion;
	public var leftTurning:Bool;
	public var turningDelay:Float;

	var playerPos:Position;
	
	public function new() {
		super();
		
		#if (cap_30 && !debug)
		sprite.loadSpriteData(R.enemyDChild, 5).animation.play();
		#else
		sprite.loadSpriteData(R.enemyDChild, 10).animation.play();
		#end
		sprite.setOrigin(21, 20);
		
		halfWidth = sprite.width / 2;
		halfHeight = sprite.height / 2;

		hpText.size = 20;
		
		addCircleMask(0, 0, 10);
		
		motion = new VelocityMotion(this);
		motion.accel = accel;
		
		playerPos = Player.instance.position;
		
		initDeathEffect();
	}
	
	override public function kill():Void {
		super.kill();
		dropGems(1, 0, 0);
	}
	
	override function updateAlive(elapsed:FastFloat):Void {
		super.updateAlive(elapsed);
		
		if (y > G.height) {
			alive = false;
			return;
		}
	
		if (turningDelay > 0) turningDelay -= elapsed;
		else {
			if (y < 300) {
				var a = Mathf.angle(x, y, playerPos.x, playerPos.y) + (leftTurning ? 360 : 0);
				var turnSpeed = Child.turnSpeed * elapsed;
				if (motion.velocity.angle >= a + turnSpeed) motion.velocity.angle -= turnSpeed;
				else if (motion.velocity.angle <= a - turnSpeed) motion.velocity.angle += turnSpeed;
				else motion.velocity.angle = a;
			}
		}
		
		rotation.angle = motion.velocity.angle + 90;
	}
	
}
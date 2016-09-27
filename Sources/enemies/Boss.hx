package enemies;

import kala.behaviors.collision.basic.Collider;
import kala.behaviors.collision.basic.shapes.CollisionCircle;
import kala.behaviors.tween.Ease;
import kala.behaviors.tween.Tween;
import kala.math.Random;
import kala.objects.group.Group;
import kala.objects.sprite.Sprite;
import kha.FastFloat;
import player.Minion;
import player.Player;
import states.PlayState;

class Boss extends Enemy {

	public static var lightningGroup:Group<Lightning> = new Group<Lightning>(false, function() return new Lightning());
	
	//
	
	public var leftThrone:Sprite;
	public var rightThrone:Sprite;
	public var leftThroneCollider:Collider;
	public var leftThroneMask:CollisionCircle;
	public var rightThroneCollider:Collider;
	public var rightThroneMask:CollisionCircle;
	public var timeline:TweenTimeline;
	
	public function new() {
		super();
		
		#if (cap_30 && !debug)
		sprite.loadSpriteData(R.boss);
		#else
		sprite.loadSpriteData(R.boss);
		#end
		
		hpText.x = halfWidth = sprite.width / 2;
		hpText.y = 50;
		hpText.size = 90;
		
		addCircleMask(halfWidth, 0, halfWidth - 90);
		mask.dynamicPosition = false;
		
		leftThrone = new Sprite().loadSpriteData(R.bossThroneBig);
		leftThrone.centerTransformation();
		leftThrone.x = -leftThrone.width;
		leftThrone.y = 200;
		
		rightThrone = new Sprite().loadSpriteData(R.bossThroneSmall);
		rightThrone.centerTransformation();
		rightThrone.x = G.width;
		rightThrone.y = 280;
		
		leftThroneCollider = new Collider(leftThrone);
		leftThroneMask = leftThroneCollider.addCircle(leftThrone.width / 2 - 5, leftThrone.height / 2 + 2, 107);
		
		rightThroneCollider = new Collider(rightThrone);
		rightThroneMask = rightThroneCollider.addCircle(rightThrone.width / 2 - 4, rightThrone.height / 2 - 6, 65);
		
		tween.get()
			.startBatch()
				.startLoop()
					#if (cap_30 && !debug)
					.tween(scale, { y: 0.9 }, 20, Ease.quadIn)
					.tween(scale, { y: 1 }, 20, Ease.quadInOut)
					#else
					.tween(scale, { y: 0.9 }, 40, Ease.quadIn)
					.tween(scale, { y: 1 }, 40, Ease.quadInOut)
					#end
				.endLoop()
				.startLoop()
					#if (cap_30 && !debug)
					.waitEx(function(_) return Random.int(50, 100))
					#else
					.waitEx(function(_) return Random.int(100, 200))
					#end
					.call(function(_) if (hp > 0) Lightning.shoot(Random.bool() ? Random.int(80, G.width - 80) : Player.instance.x))
				.endLoop()
			.endBatch()
		.start();
		
		bodyAtkOn = false;
	}
	
	override public function revive():Void {
		deathEffect.alive = false;
		alive = leftThrone.alive = rightThrone.alive = true;
		hp = 2000;
		y = -sprite.height;
		
		if (timeline != null) timeline.cancel();
		timeline = tween.get(Ease.sineInOut);
		timeline
			#if (cap_30 && !debug)
			.tween(this, { y: 0 }, 75, Ease.sineOut)
			#else
			.tween(this, { y: 0 }, 150, Ease.sineOut)
			#end
			.startBatch()
				#if (cap_30 && !debug)
				.startLoop()
					.waitEx(function(_) return Random.int(60, 120))
					.tween(leftThrone, { x: -160 }, 200)
					.waitEx(function(_) return Random.int(30, 60))
					.tween(leftThrone, { x: -leftThrone.width }, 200)
				.endLoop()
				.startLoop()
					.waitEx(function(_) return Random.int(40, 80))
					.tween(rightThrone, { x: G.width - rightThrone.width + 100 }, 100)
					.waitEx(function(_) return Random.int(30, 60))
					.tween(rightThrone, { x: G.width }, 100)
				.endLoop()
				#else
				.startLoop()
					.waitEx(function(_) return Random.int(120, 240))
					.tween(leftThrone, { x: -160 }, 400)
					.waitEx(function(_) return Random.int(60, 120))
					.tween(leftThrone, { x: -leftThrone.width }, 400)
				.endLoop()
				.startLoop()
					.waitEx(function(_) return Random.int(80, 160))
					.tween(rightThrone, { x: G.width - rightThrone.width + 100 }, 200)
					.waitEx(function(_) return Random.int(60, 120))
					.tween(rightThrone, { x: G.width }, 200)
				.endLoop()
				#end
			.endBatch()
		.start();
		
		player = PlayState.instance.player;
	}
	
	override public function kill():Void {
		timeline.cancel();
		
		tween.get()
			.startBatch()
				#if (cap_30 && !debug)
				.tween(this, { y: -sprite.height }, 150, Ease.sineIn)
				.tween(leftThrone, { x: -leftThrone.width }, 120)
				.tween(rightThrone, { x: G.width }, 120)
				#else
				.tween(this, { y: -sprite.height }, 300, Ease.sineIn)
				.tween(leftThrone, { x: -leftThrone.width }, 240)
				.tween(rightThrone, { x: G.width }, 240)
				#end
			.endBatch()
			.startLoop(8)
				.call(function(_) {
					for (i in 0...Math.round(15 * UpgradeData.gemDropFactor)) {
						Gem.create(Random.int(0, G.width), Random.int( -90, -20));
					}
				})
				#if (cap_30 && !debug)
				.wait(20)
				#else
				.wait(40)
				#end
			.endLoop()
			.call(function(_) sleep())
		.start();
		
		deathEffect.alive = true;
	}
	
	override function update(elapsed:FastFloat):Void {
		super.update(elapsed);
		leftThrone.rotation.angle++;
		rightThrone.rotation.angle -= 0.7;
	}
	
	override function updateAlive(elapsed:FastFloat):Void {
		super.updateAlive(elapsed);
		
		mask.position.y = -235 + 100 * scale.y;
		
		if (player.lives > 0 && player.flicker.flickersLeft == 0) {
			if (player.x < G.halfWidth) {
				if (leftThroneMask.available && leftThroneMask.testCircle(player.mask)) {
					player.getHit();
				}
			} else {
				if (rightThroneMask.available && rightThroneMask.testCircle(player.mask)) {
					player.getHit();
				}
			}
		}
	}
	
	public function sleep():Void {
		alive = leftThrone.alive = rightThrone.alive = false;
		leftThrone.x = -leftThrone.width;
		rightThrone.x = G.width;
		y = -sprite.height;
	}
	
}

class Lightning extends Sprite {

	public static inline function shoot(x:FastFloat):Void {
		var lightning = Boss.lightningGroup.createAlive();
		
		lightning.x = x;
		lightning.scale.x = 0;

		#if (cap_30 && !debug)
		lightning.tween.get()
			.wait(40)
			.call(function(_) G.sfxGroup.play(R.sounds.lightning, 0.5))
		.start();
		
		lightning.tween.get()
			.tween(lightning.scale, { x: Random.roll() }, 50, Ease.elasticIn)
			.wait(25)
			.tween(lightning.scale, { x: 0 }, 30, Ease.elasticInOut)
			.call(function(_) lightning.kill())
		.start();
		#else
		lightning.tween.get()
			.wait(80)
			.call(function(_) G.sfxGroup.play(R.sounds.lightning, 0.5))
		.start();
		
		lightning.tween.get()
			.tween(lightning.scale, { x: Random.roll() }, 100, Ease.elasticIn)
			.wait(50)
			.tween(lightning.scale, { x: 0 }, 30, Ease.elasticInOut)
			.call(function(_) lightning.kill())
		.start();
		#end
	}
	
	//
	
	var tween:Tween;
	var halfWidth:FastFloat;
	var player:Player;
	var playerMask:CollisionCircle;

	public function new() {
		super();
		
		#if (cap_30 && !debug)
		loadSpriteData(R.bossLightning, 2).animation.play();
		#else
		loadSpriteData(R.bossLightning, 4).animation.play();
		#end
		
		halfWidth = width / 2;
		position.ox = scale.ox = halfWidth - 5;
		position.oy = 10;
		
		tween = new Tween(this);
		
		player = PlayState.instance.player;
		playerMask = player.mask;
	}
	
	override public function kill():Void {
		super.kill();
		tween.cancel();
	}
	
	override public function update(elapsed:FastFloat):Void {
		var absScaleX = Math.abs(scale.x);
		if (absScaleX > 0.5) {
			if (
				player.lives > 0 && player.flicker.flickersLeft == 0 &&
				playerMask.absX > x - 45 * absScaleX && playerMask.absX < x + 45 * absScaleX
			) {
				player.getHit();
			}
			
			for (minion in Minion.group) {
				if (
					minion.alive && minion.lives > 0 &&
					minion.x > x - 35 * absScaleX && minion.x < x + 35 * absScaleX
				) {
					minion.getHit();
				}
			}
		}
	}
	
}
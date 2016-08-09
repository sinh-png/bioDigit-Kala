package enemies;

import kala.behaviors.tween.Ease;
import kala.behaviors.tween.Tween;
import kala.math.Random;
import kala.objects.group.Group;
import kala.objects.sprite.Sprite;
import kha.FastFloat;
import player.Player;

class Boss extends Enemy {

	public static var lightningGroup:Group<Lightning> = new Group<Lightning>(false, function() return new Lightning());
	
	//
	
	public var leftThrone:Sprite;
	public var rightThrone:Sprite;
	
	var timeline:TweenTimeline;
	
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
					.wait(Random.int(120, 240))
					#else
					.wait(Random.int(240, 480))
					#end
					.call(function(_) Lightning.shoot(Random.bool() ? Random.int(80, G.width - 80) : Player.instance.x))
				.endLoop()
			.endBatch()
		.start();
	}
	
	override public function revive():Void {
		alive = true;
		hp = 9999;
		y = -sprite.height;
		
		timeline = tween.get(Ease.sineInOut);
		
		timeline
			.tween(this, { y: 0 }, 150, Ease.sineOut)
			.startBatch()
				#if (cap_30 && !debug)
				.startLoop()
					.wait(Random.int(150, 250))
					.tween(leftThrone, { x: -160 }, 300)
					.wait(Random.int(15, 30))
					.tween(leftThrone, { x: -leftThrone.width }, 200)
				.endLoop()
				.startLoop()
					.wait(Random.int(75, 150))
					.tween(rightThrone, { x: G.width - rightThrone.width + 100 }, 250)
					.wait(Random.int(15, 30))
					.tween(rightThrone, { x: G.width }, 150)
				.endLoop()
				#else
				.startLoop()
					.wait(Random.int(300, 500))
					.tween(leftThrone, { x: -160 }, 600)
					.wait(Random.int(30, 60))
					.tween(leftThrone, { x: -leftThrone.width }, 400)
				.endLoop()
				.startLoop()
					.wait(Random.int(150, 300))
					.tween(rightThrone, { x: G.width - rightThrone.width + 100 }, 500)
					.wait(Random.int(30, 60))
					.tween(rightThrone, { x: G.width }, 300)
				.endLoop()
				#end
			.endBatch()
		.start();
	}
	
	override public function kill():Void {
		
	}
	
	override function updateAlive(elapsed:FastFloat):Void {
		super.updateAlive(elapsed);
		
		mask.position.y = -235 + 100 * scale.y;
		leftThrone.rotation.angle++;
		rightThrone.rotation.angle--;
	}
	
}

class Lightning extends Sprite {

	public static inline function shoot(x:FastFloat):Void {
		var lightning = Boss.lightningGroup.createAlive();
		
		lightning.x = x;
		lightning.scale.x = 0;
		
		#if (cap_30 && !debug)
		lightning.tween.get()
			.tween(lightning.scale, { x: 1 * Random.roll() }, 50, Ease.elasticIn)
			.wait(25)
			.tween(lightning.scale, { x: 0 }, 30, Ease.elasticInOut)
			.call(function(_) lightning.kill())
		.start();
		#else
		lightning.tween.get()
			.tween(lightning.scale, { x: 1 * Random.roll() }, 100, Ease.elasticIn)
			.wait(50)
			.tween(lightning.scale, { x: 0 }, 30, Ease.elasticInOut)
			.call(function(_) lightning.kill())
		.start();
		#end
	}
	
	//
	
	var tween:Tween;
	var halfWidth:FastFloat;
	
	public function new() {
		super();
		
		#if (cap_30 && !debug)
		loadSpriteData(R.bossLightning, 2).animation.play();
		#else
		loadSpriteData(R.bossLightning, 4).animation.play();
		#end
		
		halfWidth = position.ox = scale.ox = width / 2;
		position.oy = 10;
		
		tween = new Tween(this);
	}
	
	override public function update(elapsed:FastFloat):Void {
		
	}
	
}
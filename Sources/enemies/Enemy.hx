package enemies;

import kala.behaviors.collision.basic.Collider;
import kala.behaviors.collision.basic.shapes.CollisionCircle;
import kala.behaviors.tween.Ease;
import kala.behaviors.tween.Tween;
import kala.math.Mathf;
import kala.math.Random;
import kala.objects.group.Group;
import kala.objects.sprite.Sprite;
import kala.objects.text.BasicText;
import kha.FastFloat;

class Enemy extends GenericGroup {

	#if (cap_30 && !debug)
	static inline var deathEffectTotalFrames = 15;
	#else
	static inline var deathEffectTotalFrames = 30;
	#end
	
	//
	
	public var collider:Collider;
	public var mask:CollisionCircle;
	
	public var hp(default, set):FastFloat;
	
	public var sprite:Sprite;
	var hpText:BasicText;
	var deathEffect:Sprite;
	
	var tween:Tween;
	
	var halfWidth:FastFloat;
	var halfHeight:FastFloat;
	
	public function new() {
		super(true);
		
		sprite = new Sprite();
		add(sprite);
		
		hpText = new BasicText(R.fonts.font_1, 90);
		add(hpText);
		
		deathEffect = new Sprite();
		deathEffect.kill();
		add(deathEffect);
		
		collider = new Collider(this);
		tween = new Tween(this);
	}
	
	override public function revive():Void {
		super.revive();
		sprite.revive();
		hpText.revive();
		mask.active = true;
		timeScale = 1;
	}
	
	override public function kill():Void {
		sprite.kill();
		hpText.kill();
		mask.active = false;
		
		deathEffect.position.setXY(sprite.position.x, sprite.position.y);
		deathEffect.scale.set(1, 1, halfWidth, halfHeight);
		deathEffect.opacity = 1;
		deathEffect.revive();
		
		tween.get(deathEffect)
			.startBatch()
				.tweenXY(deathEffect.scale, 3, 3, deathEffectTotalFrames, Ease.cubeOut)
				.tween(null, { opacity: 0 }, deathEffectTotalFrames)
			.endBatch()
			.call(function(timeline) {
				timeline.cancel();
				alive = false;
				deathEffect.kill();
				put();
			})
		.start();
	}
	
	override public function update(elapsed:FastFloat):Void {
		super.update(elapsed);
		
		if (sprite.alive) updateAlive(elapsed);
	
		timeScale = 1;
	}
	
	inline function moveRandom(actionCB:Void->Void):Void {
		var x = Mathf.clamp(this.x + Random.int( -100, 100), halfWidth, G.width - halfWidth);
		var y = Mathf.clamp(this.y + Random.int( -100, 100), halfHeight, 200);
		#if (cap_30 && !debug)
		var t = Mathf.distance(this.x, this.y, x, y) / Random.float(0.5, 1);
		#else
		var t = Mathf.distance(this.x, this.y, x, y) / Random.float(0.25, 0.5);
		#end
		tween.get()
			.tween(this, { x: x, y: y }, t, Ease.sineInOut)
			.call(function(_) actionCB())
			#if (cap_30 && !debug)
			.wait(Random.float(30, 60))
			#else
			.wait(Random.float(60, 120))
			#end
			.call(function(_) moveRandom(actionCB))
		.start();
	}
	
	function put():Void {
		
	}
	
	function updateAlive(elapsed:FastFloat):Void {
		
	}

	function spawnRandomPos():Void {
		
	}
	
	inline function addCircleMask(x:FastFloat, y:FastFloat, radius:FastFloat):Void {
		mask = collider.addCircle(x, y, radius);
	}
	
	inline function initDeathEffect():Void {
		deathEffect.image = sprite.image;
		deathEffect.frameRect.copy(sprite.frameRect);
		deathEffect.position.setOrigin(sprite.position.ox, sprite.position.oy);
	}
	
	inline function dropGems(quantity:Int, offsetX:FastFloat = 0, offsetY:FastFloat = 0):Void {
		for (i in 0...quantity) Gem.create(x + offsetX, y + offsetY);
	}
	
	function set_hp(value:FastFloat):FastFloat {
		if (deathEffect.alive) return hp;
		
		hp = value;
		value = Std.int(value);
		
		if (value <= 0) {
			value = 0;
			kill();
		}
		
		hpText.text = "" + value;
		hpText.position.setOrigin(hpText.width / 2, hpText.height / 2);
	
		return hp;
	}
	
}
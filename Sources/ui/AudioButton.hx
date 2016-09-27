package ui;

import kala.behaviors.tween.Ease;
import kala.behaviors.tween.Tween;
import kala.objects.sprite.BasicButtonSprite;
import kha.FastFloat;

class AudioButton extends BasicButtonSprite {

	var tween:Tween;
	
	public function new() {
		super();
		
		loadSpriteData(R.sheets.sprite_sheet_1.get("audio_button/", R.images.sprite_sheet_1), "_");
		animation.play("_");
		animation.frame = 1;
		
		addObjectRectMask();
		
		onOut.notify(onOutHandle);
		onOver.notify(onOverHandle);
		onPush.notify(onPushHandle);
		
		kill();
		x = -width;
		y = 7;
		tween = new Tween(this);
	}
	
	public function show():Void {
		if (alive) return;
		
		revive();
		opacity = 0.6;
		tween.get()
			#if (cap_30 && !debug)
			.tween(this, { x: 5 }, 15, Ease.sineOut)
			#else
			.tween(this, { x: 5 }, 30, Ease.sineOut)
			#end
		.start();
	}
	
	public function hide():Void {
		tween.get()
			#if (cap_30 && !debug)
			.tween(this, { x: -width }, 15, Ease.sineIn)
			#else
			.tween(this, { x: -width }, 30, Ease.sineIn)
			#end
			.call(function(_) kill())
		.start();
	}
	
	function onOutHandle(_):Void {
		opacity = 0.6;
	}
	
	function onOverHandle(_):Void {
		opacity = 1;
	}
	
	function onPushHandle(_, _):Void {
		G.audioMuted = !G.audioMuted;
		Save.save();
	}
	
}
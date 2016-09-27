package states;

import kala.audio.Audio;
import kala.behaviors.tween.Ease;
import kala.behaviors.tween.Tween;
import kala.objects.group.Group.GenericGroup;
import kala.objects.sprite.Sprite;

class SpringRollSplash extends GenericGroup {

	var background:Sprite;
	var logo:Sprite;
	
	public function new() {
		super();
		
		background = new Sprite(R.images.background_blur);
		add(background);
		
		logo = new Sprite().loadSpriteData(R.sheets.sprite_sheet_1.get("springroll_logo.png", R.images.sprite_sheet_1));
		logo.position.setOrigin(logo.width / 2, logo.height / 2).setXY(G.width / 2, G.height + 300);
		logo.rotation.setPivot(logo.width / 2, logo.height / 2);
		logo.antialiasing = true;
		add(logo);

		var tween = new Tween(logo);
		tween.get()
			.startBatch()
				.tween(null, { y: G.height / 2 - 30 }, 40, Ease.quadOut)
				.tweenAngle(null, 180, 360, 90, Ease.backOut)
			.endBatch()
			.wait(60)
			.tween(null, { x: -logo.width }, 60, Ease.backIn)
			.wait(20)
			.call(function(_) {
				MainMenuState.instance.onFirstFrame.notify(onMainMenuStarted);
				G.switchState(MainMenuState.instance);
			})
		.start();
	}
	
	override public function destroy(destroyBehaviors:Bool = true):Void {
		super.destroy(destroyBehaviors);
		background = null;
		logo = null;
	}
	
	function onMainMenuStarted(_):Void {
		G.bgmChannel = Audio.play(R.sounds.Dissonant_Waltz, 1, true);
		MainMenuState.instance.onFirstFrame.remove(onMainMenuStarted);
		G.init();
		Save.load();
		destroy();
	}
	
}
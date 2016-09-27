package states;

import kala.behaviors.tween.Ease;
import kala.behaviors.tween.Tween;
import kala.Kala;
import kala.objects.group.Group;
import kala.objects.group.Group.GenericGroup;
import kala.objects.sprite.ButtonSprite;
import kala.objects.sprite.Sprite;
import ui.Button;

class MainMenuState extends GenericGroup {

	public static var instance:MainMenuState;
	
	//
	
	var tween:Tween;
	
	var background:Sprite;
	var title:Sprite;
	
	var buttonsGroup:GenericGroup;
	var playButton:Button;
	var helpButton:Button;
	var settingsButton:Button;
	var creditButton:Button;
	var androidButton:Button;
	
	var picker:Sprite;
	
	public function new() {
		super();
	
		onFirstFrame.notify(onStartHandle);
		
		tween = new Tween(this);
		
		background = new Sprite(R.images.background_blur);
		add(background);
		
		title = new Sprite().loadSpriteData(R.sheets.sprite_sheet_1.get("main_menu/title.png", R.images.sprite_sheet_1));
		title.position.y = -title.height;
		add(title);
		
		buttonsGroup = new GenericGroup(true);
		buttonsGroup.setXY((G.width - 320) / 2 + 10, G.height);
		buttonsGroup.active = false;
		add(buttonsGroup);
		
		playButton = new Button("play", R.sheets.sprite_sheet_1.get("main_menu/play_button.png", R.images.sprite_sheet_1), true);
		playButton.mask.scale.set(0.8, 0.9);
		playButton.onOver.notify(onButtonHoveredHandle);
		playButton.onOut.notify(onButtonOutHandle);
		playButton.onRelease.notify(onButtonReleaseHandle);
		buttonsGroup.add(playButton);
		
		helpButton = new Button("help", R.sheets.sprite_sheet_1.get("main_menu/help_button.png", R.images.sprite_sheet_1), true);
		helpButton.onOver.notify(onButtonHoveredHandle);
		helpButton.onOut.notify(onButtonOutHandle);
		helpButton.onRelease.notify(onButtonReleaseHandle);
		buttonsGroup.add(helpButton);
		
		settingsButton = new Button("settings", R.sheets.sprite_sheet_1.get("main_menu/settings_button.png", R.images.sprite_sheet_1), true);
		settingsButton.onOver.notify(onButtonHoveredHandle);
		settingsButton.onOut.notify(onButtonOutHandle);
		settingsButton.onRelease.notify(onButtonReleaseHandle);
		buttonsGroup.add(settingsButton);
		
		creditButton = new Button("credit", R.sheets.sprite_sheet_1.get("main_menu/credit_button.png", R.images.sprite_sheet_1), true);
		creditButton.mask.scale.set(0.9, 0.95);
		creditButton.onOver.notify(onButtonHoveredHandle);
		creditButton.onOut.notify(onButtonOutHandle);
		creditButton.onRelease.notify(onButtonReleaseHandle);
		buttonsGroup.add(creditButton);
		
		androidButton = new Button("android", R.sheets.sprite_sheet_1.get("main_menu/android_badge.png", R.images.sprite_sheet_1), true);
		androidButton.centerTransformation();
		androidButton.antialiasing = true;
		androidButton.onOver.notify(onButtonHoveredHandle);
		androidButton.onOut.notify(onButtonOutHandle);
		androidButton.onRelease.notify(onButtonReleaseHandle);
		buttonsGroup.add(androidButton);
		
		playButton.position.setXBetween(0, 320, 0);
		helpButton.position.setXBetween(0, 320, Std.int(100 / 3));
		settingsButton.position.setXBetween(0, 320, Std.int(100 / 3 * 2));
		creditButton.position.setXBetween(0, 320, 100);
		
		androidButton.position.setXBetween(0, 320);
		androidButton.y = playButton.height + 30;
		
		picker = new Sprite().loadSpriteData(R.sheets.sprite_sheet_1.get("main_menu/picker.png", R.images.sprite_sheet_1));
		picker.centerOrigin();
		picker.visible = false;
		buttonsGroup.add(picker);
	}
	
	function onStartHandle(_):Void {
		Kala.updateRate = 60;
		
		tween.get(Ease.sineOut)
			.startBatch()
				.tween(title, { y: 0 }, 36)
				.tween(buttonsGroup, { y: 280 }, 36)
			.endBatch()
			.call(function(_) buttonsGroup.active = true)
		.start();
		
		G.audioButton.show();
	}
	
	function onButtonHoveredHandle(button:ButtonSprite):Void {
		if (button.data == "android") return;
		
		picker.visible = true;
			
		switch(button.data) {
			case "play": picker.setXY(playButton.x - 10, playButton.y + 24);
			case "help": picker.setXY(helpButton.x, helpButton.y + 21);
			case "settings": picker.setXY(settingsButton.x - 2, settingsButton.y + 33);
			case "credit": picker.setXY(creditButton.x - 6, creditButton.y + 25);
		}
	}
	
	function onButtonOutHandle(button:ButtonSprite):Void {
		if (button.data == "android") return;
		picker.visible = false;
	}
	
	function onButtonReleaseHandle(button:ButtonSprite, _):Void {
		switch(button.data) {
			case "play": play();
			case "help": startTutorial();
			case "settings": openSettings();
			case "credit": openCredit();
			case "android":  Kala.openURL("https://play.google.com/store/apps/details?id=me.haza.biodigit&hl=en");
		}
	}
	
	function play():Void {
		if (G.tutorialPassed) {
			close(function() G.switchState(UpgradeState.instance));
		} else {
			startTutorial();
		}
	}
	
	function startTutorial():Void {
		UpgradeData.update([0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
		PlayState.instance.tutorialState = 0;
		close(function() G.switchState(PlayState.instance));
	}
	
	function openSettings():Void {
		close(function() G.switchState(SettingMenuState.instance));
	}
	
	function openCredit():Void {
		close(function() G.switchState(CreditState.instance));
	}
	
	function close(cb:Void->Void):Void {
		buttonsGroup.active = false;
		picker.visible = false;
		
		tween.cancel();
		tween.get(Ease.sineOut)
			.startBatch()
				.tween(title, { y: -title.height }, 36)
				.tweenXY(buttonsGroup, (G.width - 320) / 2 + 10, G.height, 36)
			.endBatch()
			.call(function(_) cb())
		.start();
	}
	
}
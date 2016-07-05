package states;

import kala.behaviors.tween.Ease;
import kala.behaviors.tween.Tween;
import kala.Kala;
import kala.objects.group.Group;
import kala.objects.group.Group.GenericGroup;
import kala.objects.sprite.PushSprite;
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
	var moreGamesButton:Button;
	
	var picker:Sprite;
	
	public function new() {
		super();
	
		onFirstFrame.notify(onStart);
		
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
		playButton.onOver.notify(onButtonHovered);
		playButton.onOut.notify(onButtonOut);
		playButton.onRelease.notify(onButtonRelease);
		buttonsGroup.add(playButton);
		
		helpButton = new Button("help", R.sheets.sprite_sheet_1.get("main_menu/help_button.png", R.images.sprite_sheet_1), true);
		helpButton.onOver.notify(onButtonHovered);
		helpButton.onOut.notify(onButtonOut);
		helpButton.onRelease.notify(onButtonRelease);
		buttonsGroup.add(helpButton);
		
		settingsButton = new Button("settings", R.sheets.sprite_sheet_1.get("main_menu/settings_button.png", R.images.sprite_sheet_1), true);
		settingsButton.onOver.notify(onButtonHovered);
		settingsButton.onOut.notify(onButtonOut);
		settingsButton.onRelease.notify(onButtonRelease);
		buttonsGroup.add(settingsButton);
		
		creditButton = new Button("credit", R.sheets.sprite_sheet_1.get("main_menu/credit_button.png", R.images.sprite_sheet_1), true);
		creditButton.mask.scale.set(0.9, 0.95);
		creditButton.onOver.notify(onButtonHovered);
		creditButton.onOut.notify(onButtonOut);
		creditButton.onRelease.notify(onButtonRelease);
		buttonsGroup.add(creditButton);
		
		moreGamesButton = new Button("moregames", R.sheets.sprite_sheet_1.get("main_menu/more_game_button.png", R.images.sprite_sheet_1), true);
		moreGamesButton.centerTransformation();
		moreGamesButton.antialiasing = true;
		moreGamesButton.onOver.notify(onButtonHovered);
		moreGamesButton.onOut.notify(onButtonOut);
		moreGamesButton.onRelease.notify(onButtonRelease);
		buttonsGroup.add(moreGamesButton);
		
		playButton.position.setXBetween(0, 320, 0);
		helpButton.position.setXBetween(0, 320, Std.int(100 / 3));
		settingsButton.position.setXBetween(0, 320, Std.int(100 / 3 * 2));
		creditButton.position.setXBetween(0, 320, 100);
		
		moreGamesButton.position.setXBetween(0, 320);
		moreGamesButton.y = playButton.height + 30;
		
		picker = new Sprite().loadSpriteData(R.sheets.sprite_sheet_1.get("main_menu/picker.png", R.images.sprite_sheet_1));
		picker.centerOrigin();
		picker.visible = false;
		buttonsGroup.add(picker);
	}
	
	function onStart(_):Void {
		Kala.updateRate = 60;
		
		tween.get(Ease.sineOut)
			.startBatch()
				.tween(title, { y: 0 }, 36)
				.tween(buttonsGroup, { y: 280 }, 36)
			.endBatch()
			.call(function(_) buttonsGroup.active = true)
		.start();
	}
	
	function onButtonHovered(button:PushSprite):Void {
		if (button.data == "moregames") moreGamesButton.scale.setXY(1.2, 1.2);
		else {
			picker.visible = true;
			
			switch(button.data) {
				case "play": picker.setXY(playButton.x - 10, playButton.y + 24);
				case "help": picker.setXY(helpButton.x, helpButton.y + 21);
				case "settings": picker.setXY(settingsButton.x - 2, settingsButton.y + 33);
				case "credit": picker.setXY(creditButton.x - 6, creditButton.y + 25);
			}
		}
	}
	
	function onButtonOut(button:PushSprite):Void {
		if (button.data == "moregames") moreGamesButton.scale.setXY(1, 1);
		else picker.visible = false;
	}
	
	function onButtonRelease(button:PushSprite, _):Void {
		switch(button.data) {
			case "play": play();
			case "help": openInstruction();
			case "settings": openSettings();
			case "credit": openCredit();
			case "moregames":  Kala.openURL("http://yourwebsite.abc");
		}
	}
	
	function play():Void {
		close(function() G.switchState(PlayState.instance));
	}
	
	function openInstruction():Void {
		
	}
	
	function openSettings():Void {
		
	}
	
	function openCredit():Void {
		
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
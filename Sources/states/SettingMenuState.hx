package states;

import kala.behaviors.input.ButtonInteraction;
import kala.behaviors.tween.Ease;
import kala.behaviors.tween.Tween;
import kala.input.Mouse;
import kala.input.Touch;
import kala.Kala;
import kala.objects.group.Group.GenericGroup;
import kala.objects.Object;
import kala.objects.shapes.Rectangle;
import kala.objects.sprite.ButtonSprite;
import kala.objects.sprite.Sprite;
import kala.objects.text.BasicText;
import kala.objects.text.Text;
import kala.objects.text.TextAlign;
import kha.FastFloat;

class SettingMenuState extends GenericGroup {
	
	public static var instance:SettingMenuState;
	
	public var tween:Tween;
	
	public var background:Sprite;
	public var backButton:ButtonSprite;
	public var soundButton:ButtonSprite;
	public var musicButton:ButtonSprite;
	public var soundBars:Array<ButtonSprite>;
	public var musicBars:Array<ButtonSprite>;
	public var resetButton:ButtonSprite;
	
	public var resetConfirmationText:Text;
	public var resetOptionsBG:Rectangle;
	public var resetYesText:BasicText;
	public var resetNoText:BasicText;
	
	public var barsActive:Bool;

	public function new() {
		super();
		
		tween = new Tween(this);
		
		onFirstFrame.notify(onStartHandle);
		
		background = new Sprite(R.images.background_blur);
		add(background);
		
		backButton = new ButtonSprite();
		backButton.loadSpriteData(R.sheets.sprite_sheet_1.get("settings_menu/back_button.png", R.images.sprite_sheet_1));
		backButton.addObjectRectMask();
		backButton.y = 7;
		backButton.data = { kind: "button", type: "back" };
		backButton.onOver.notify(onOverHandle);
		backButton.onOut.notify(onOutHandle);
		backButton.onPush.notify(onPushHandle);
		add(backButton);
		
		soundButton = new ButtonSprite();
		soundButton.loadSpriteData(R.sheets.sprite_sheet_1.get("settings_menu/sound_icon.png", R.images.sprite_sheet_1));
		soundButton.centerTransformation();
		soundButton.y = 140;
		soundButton.data = { kind: "button", type: "sound" };
		soundButton.addObjectRectMask().scale.set(0.8, 0.8, soundButton.width / 2, soundButton.height / 2);
		soundButton.onOver.notify(onOverHandle);
		soundButton.onOut.notify(onOutHandle);
		soundButton.onPush.notify(onPushHandle);
		add(soundButton);
		
		musicButton = new ButtonSprite();
		musicButton.loadSpriteData(R.sheets.sprite_sheet_1.get("settings_menu/music_icon.png", R.images.sprite_sheet_1));
		musicButton.centerTransformation();
		musicButton.y = soundButton.y + soundButton.height;
		musicButton.data = { kind: "button", type: "music" };
		musicButton.addObjectRectMask().scale.set(1.06, 0.8, -100, musicButton.height / 2);
		musicButton.onOver.notify(onOverHandle);
		musicButton.onOut.notify(onOutHandle);
		musicButton.onPush.notify(onPushHandle);
		add(musicButton);
		
		var barSpriteData = R.sheets.sprite_sheet_1.get("settings_menu/volume_bar.png", R.images.sprite_sheet_1);
		
		soundBars = new Array<ButtonSprite>();
		var bar:ButtonSprite;
		for (i in 0...20) {
			bar = new ButtonSprite();
			bar.loadSpriteData(barSpriteData);
			bar.scale.oy = bar.height / 2;
			bar.x = soundButton.x + soundButton.width + (2 + bar.width) * i;
			bar.y = soundButton.y + 15;
			bar.data = { kind: "bar", type: "sound", id: i };
			bar.addObjectRectMask();
			bar.onOver.notify(onOverHandle);
			bar.onOut.notify(onOutHandle);
			bar.onPush.notify(onPushHandle);
			soundBars.push(bar);
			add(bar);
		}
		
		musicBars = new Array<ButtonSprite>();
		var bar:ButtonSprite;
		for (i in 0...20) {
			bar = new ButtonSprite();
			bar.loadSpriteData(barSpriteData);
			bar.scale.oy = bar.height / 2;
			bar.x = musicButton.x + soundButton.width + (2 + bar.width) * i;
			bar.y = musicButton.y + 15;
			bar.data = { kind: "bar", type: "music", id: i };
			bar.addObjectRectMask();
			bar.onOver.notify(onOverHandle);
			bar.onOut.notify(onOutHandle);
			bar.onPush.notify(onPushHandle);
			musicBars.push(bar);
			add(bar);
		}
		
		resetButton = new ButtonSprite();
		resetButton.loadSpriteData(R.sheets.sprite_sheet_1.get("settings_menu/reset_button.png", R.images.sprite_sheet_1));
		resetButton.centerTransformation();
		resetButton.addObjectRectMask();
		resetButton.x = 460;
		resetButton.data = { kind: "button", type: "reset" };
		resetButton.onOver.notify(onOverHandle);
		resetButton.onOut.notify(onOutHandle);
		resetButton.onPush.notify(onPushHandle);
		add(resetButton);
		
		resetConfirmationText = new Text("This will reset all your process.\nAre you sure you want to do this?", 30, G.width);
		resetConfirmationText.y = 140;
		resetConfirmationText.textColor = 0xffff2222;
		resetConfirmationText.align = TextAlign.CENTER;
		resetConfirmationText.bgOpacity = 0.5;
		resetConfirmationText.bgColor = 0xff000000;
		resetConfirmationText.padding.set(30, 5);
		resetConfirmationText.kill();
		add(resetConfirmationText);
		
		resetYesText = new BasicText("YES", 30);
		resetYesText.position.setXY(220, 240);
		resetYesText.color = resetConfirmationText.textColor;
		resetYesText.centerTransformation();
		resetYesText.kill();
		
		resetNoText = new BasicText("NO", 30);
		resetNoText.position.setXY(G.width - resetNoText.width - resetYesText.x, 240);
		resetNoText.color = 0xff00ffff;
		resetNoText.centerTransformation();
		resetNoText.kill();
		
		var buttonBehavior = new ButtonInteraction(resetYesText);
		buttonBehavior.addObjectRectMask();
		buttonBehavior.onOver.notify(onOverResetOptionText);
		buttonBehavior.onOut.notify(onOutResetOptionText);
		buttonBehavior.onRelease.notify(function(_, _) {
			closeResetConfirmation();
			Save.reset();
		});
		
		var buttonBehavior = new ButtonInteraction(resetNoText);
		buttonBehavior.addObjectRectMask();
		buttonBehavior.onOver.notify(onOverResetOptionText);
		buttonBehavior.onOut.notify(onOutResetOptionText);
		buttonBehavior.onRelease.notify(function(_, _) closeResetConfirmation());
		
		resetOptionsBG = new Rectangle(G.width, cast resetYesText.height + 10);
		resetOptionsBG.fillOpacity = 0.5;
		resetOptionsBG.fillColor = 0xff000000;
		resetOptionsBG.y = resetYesText.y - 5;
		resetOptionsBG.kill();
		add(resetOptionsBG);
		
		add(resetYesText);
		add(resetNoText);
		
		backButton.visible =
		soundButton.visible =
		musicButton.visible =
		resetButton.visible = false;
		for (bar in soundBars) bar.visible = false;
		for (bar in musicBars) bar.visible = false;
	}
	
	override public function update(elapsed:FastFloat):Void {
		super.update(elapsed);
		
		for (i in 0...soundBars.length) {
			soundBars[i].x = soundButton.x + soundButton.width + (2 + soundBars[i].width) * i;
		}
		
		for (i in 0...musicBars.length) {
			musicBars[i].x = musicButton.x + soundButton.width + (2 + musicBars[i].width) * i;
		}
		
		if (!barsActive) {
			#if js
			if ((Kala.html5.mobile && Touch.touches.count == 0) || (!Kala.html5.mobile && Mouse.ANY.justReleased)) {
			#else
			if (Mouse.ANY.justReleased) {
			#end
				barsActive = true;
			}
		}
		
	}
	
	function onStartHandle(_):Void {
		var w = soundBars[19].x + soundBars[0].width - soundButton.x;
		var x = (G.width - w) / 2;
		
		backButton.active = false;
		backButton.opacity = 0.7;
		backButton.x = G.width;
		soundButton.x = -w;
		musicButton.x = G.width;
		resetButton.y = G.height;
		barsActive = true;
		
		tween.get()
			.wait(1)
			.call(function(_) {
				backButton.visible =
				soundButton.visible =
				musicButton.visible =
				resetButton.visible = true;
				for (bar in soundBars) bar.visible = true;
				for (bar in musicBars) bar.visible = true;
			})
			.startBatch()
				.tween(backButton, { x: G.width - backButton.width - 7 }, 30, Ease.sineOut)
				.tween(soundButton, { x: x - 10 }, 30, Ease.sineOut)
				.tween(musicButton, { x: x - 10 }, 30, Ease.sineOut)
				.tween(resetButton, { y: musicButton.y + musicButton.height }, 30, Ease.sineOut)
			.endBatch()
			.call(function(_) backButton.active = true)
		.start();
	}
	
	function onOverHandle(button:ButtonSprite):Void {
		var type = button.data.type;
		
		if (button.data.kind == "button") {
			if (button.data.type == "back") {
				button.opacity = 1;
			} else {
				button.scale.setXY(1.2, 1.2);
				
				#if js
				if (Kala.html5.mobile || (!Kala.html5.mobile && Mouse.ANY.pressed)) {
				#else
				if (Mouse.ANY.pressed) {
				#end
					if (type == "sound") G.soundVolume = G.soundVolume == 0 ? 1 : 0;
					else if (type == "music") G.musicVolume = G.musicVolume == 0 ? 1 : 0;
				}
			}
		} else if (barsActive) {
			button.scale.y = 1.2;
			
			#if js
			if (Kala.html5.mobile || (!Kala.html5.mobile && Mouse.ANY.pressed)) {
			#else
			if (Mouse.ANY.pressed) {
			#end
				if (type == "sound") G.soundVolume = (button.data.id + 1) / 20;
				else G.musicVolume = (button.data.id + 1) / 20;
			}
		}
	}
	
	function onOutHandle(button:ButtonSprite):Void {
		if (button.data.type == "back") {
			button.opacity = 0.7;
		} else {
			button.scale.setXY(1, 1);
		}
	}
	
	function onPushHandle(button:ButtonSprite, _):Void {
		var type = button.data.type;
		
		if (button.data.kind == "button") {
			if (type == "back") backToMainMenu();
			else if (type == "sound") G.soundVolume = G.soundVolume == 0 ? 1 : 0;
			else if (type == "music") G.musicVolume = G.musicVolume == 0 ? 1 : 0;
			else openResetConfirmation();
		} else {
			if (type == "sound") G.soundVolume = (button.data.id + 1) / 20;
			else if (type == "music") G.musicVolume = (button.data.id + 1) / 20;
		}
	}
	
	function onOverResetOptionText(behavior:ButtonInteraction):Void {
		behavior.object.scale.setXY(1.2, 1.2);
	}
	
	function onOutResetOptionText(behavior:ButtonInteraction):Void {
		behavior.object.scale.setXY(1, 1);
	}
	
	function openResetConfirmation():Void {
		backButton.alive = soundButton.alive = musicButton.alive = resetButton.alive = false;
		for (bar in soundBars) bar.kill();
		for (bar in musicBars) bar.kill();
		resetConfirmationText.alive = resetOptionsBG.alive = resetYesText.alive = resetNoText.alive = true;
	}
	
	function closeResetConfirmation():Void {
		resetConfirmationText.alive = resetOptionsBG.alive = resetYesText.alive = resetNoText.alive = false;
		backButton.alive = soundButton.alive = musicButton.alive = resetButton.alive = true;
		for (bar in soundBars) bar.revive();
		for (bar in musicBars) bar.revive();
		barsActive = false;
	}
	
	function backToMainMenu():Void {
		backButton.active = false;
		tween.get()
			.startBatch()
				.tween(backButton, { x: G.width }, 30, Ease.sineIn)
				.tween(soundButton, { x: -soundBars[19].x + soundBars[0].width - soundButton.x }, 30, Ease.sineIn)
				.tween(musicButton, { x: G.width }, 30, Ease.sineIn)
				.tween(resetButton, { y: G.height }, 30, Ease.sineIn)
			.endBatch()
			.call(function(_) G.switchState(MainMenuState.instance))
		.start();
		
		Save.save();
	}
}
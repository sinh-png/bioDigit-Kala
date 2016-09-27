package;

import kala.audio.AudioChannel;
import kala.audio.AudioGroup;
import kala.Kala;
import kala.objects.group.Group.GenericGroup;
import kala.objects.group.View;
import kala.objects.sprite.ButtonSprite;
import states.SettingMenuState;
import ui.AudioButton;

class G {

	public static inline var width = 700;
	public static inline var height = 495;
	public static inline var halfWidth = width / 2;
	
	public static var tutorialPassed:Bool;
	public static var state:GenericGroup;
	
	public static var audioButton:AudioButton;
	public static var audioMuted(default, set):Bool;
	public static var soundVolume(default, set):Float;
	public static var musicVolume(default, set):Float;
	
	public static var bgmChannel:AudioChannel;
	public static var sfxGroup:AudioGroup = new AudioGroup();
	
	public static var touchControl:Bool;
	
	public static function init():Void {
		tutorialPassed = false;
		audioMuted = false;
		soundVolume = 1;
		musicVolume = 1;
		UpgradeData.money = 0;
		UpgradeData.itemLevel = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
		
		#if flash
		touchControl = false;
		#elseif js
		touchControl = Kala.html5.mobile;
		#end
	}
	
	public static inline function switchState(state:GenericGroup):Void {
		Kala.world.swap(G.state, state);
		G.state = state;
	}
	
	static function set_audioMuted(value:Bool):Bool {
		bgmChannel.muted = sfxGroup.muted = value;
		audioButton.animation.frame = value ? 0 : 1;
		return audioMuted = value;
	}
	
	static function set_soundVolume(value:Float):Float {
		sfxGroup.volume = value;
		
		var a = Std.int(value * 20);
		var bar:ButtonSprite;
		for (i in 0...20) {
			bar = SettingMenuState.instance.soundBars[i];
			bar.opacity = bar.data.id < a ? 1 : 0.5;
		}
		return soundVolume = value;
	}
	
	static function set_musicVolume(value:Float):Float {
		bgmChannel.volume = value;
		
		var a = Std.int(value * 20);
		var bar:ButtonSprite;
		for (i in 0...20) {
			bar = SettingMenuState.instance.musicBars[i];
			bar.opacity = bar.data.id < a ? 1 : 0.5;
		}
		return musicVolume = value;
	}
	
}
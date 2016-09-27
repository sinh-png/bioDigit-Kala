package;

import kha.Storage;

class Save {
	
	/**
	 * Unable to load correct values from array from written object.
	 * Avod using serialization for better performance.
	 */
	
	public static function save():Void {
		Storage.defaultFile().writeObject( {
			money: UpgradeData.money,
			itemLevel0: UpgradeData.itemLevel[0],
			itemLevel1: UpgradeData.itemLevel[1],
			itemLevel2: UpgradeData.itemLevel[2],
			itemLevel3: UpgradeData.itemLevel[3],
			itemLevel4: UpgradeData.itemLevel[4],
			itemLevel5: UpgradeData.itemLevel[5],
			itemLevel6: UpgradeData.itemLevel[6],
			itemLevel7: UpgradeData.itemLevel[7],
			itemLevel8: UpgradeData.itemLevel[8],
			itemLevel9: UpgradeData.itemLevel[9],
			
			audioMuted: G.audioMuted,
			soundVolume: G.soundVolume,
			musicVolume: G.musicVolume,
			tutorialPassed: G.tutorialPassed
		});
	}
	
	public static function load():Void {
		var data:SaveData = Storage.defaultFile().readObject();
		
		if (data == null) return;
		
		UpgradeData.money = data.money;
		UpgradeData.itemLevel[0] = data.itemLevel0;
		UpgradeData.itemLevel[1] = data.itemLevel1;
		UpgradeData.itemLevel[2] = data.itemLevel2;
		UpgradeData.itemLevel[3] = data.itemLevel3;
		UpgradeData.itemLevel[4] = data.itemLevel4;
		UpgradeData.itemLevel[5] = data.itemLevel5;
		UpgradeData.itemLevel[6] = data.itemLevel6;
		UpgradeData.itemLevel[7] = data.itemLevel7;
		UpgradeData.itemLevel[8] = data.itemLevel8;
		UpgradeData.itemLevel[9] = data.itemLevel9;
		
		G.audioMuted = data.audioMuted;
		G.soundVolume = data.soundVolume;
		G.musicVolume = data.musicVolume;
		G.tutorialPassed = data.tutorialPassed;
	}
	
	public static function reset():Void {
		UpgradeData.money = 0;
		UpgradeData.itemLevel = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
		G.tutorialPassed = false;
		save();
	}
	
}

typedef SaveData = {
	
	var money:Int;
	var itemLevel0:Int;
	var itemLevel1:Int;
	var itemLevel2:Int;
	var itemLevel3:Int;
	var itemLevel4:Int;
	var itemLevel5:Int;
	var itemLevel6:Int;
	var itemLevel7:Int;
	var itemLevel8:Int;
	var itemLevel9:Int;
	
	var audioMuted:Bool;
	var soundVolume:Float;
	var musicVolume:Float;
	var tutorialPassed:Bool;
	
}
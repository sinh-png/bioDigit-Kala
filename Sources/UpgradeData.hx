package;

import kha.FastFloat;

class UpgradeData {
	
	public static var money:Int = 99999;

	public static var startingLives:Int;
	public static var shootDelay:Int;
	public static var bulletsPerShot:Int;
	public static var middleBulletIndex:Int;
	public static var webDuration:Int;
	public static var lightningDMG:FastFloat;
	public static var gemDropFactor:FastFloat;
	public static var minionSpawnDelay:Int;
	public static var minionStartingLives:Int;
	public static var minionShootDelay:Int;
	public static var minionLightningChance:Int;
	public static var gemCollectionDistance:Int;
	
	public static var itemLevel:Array<Int> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
	public static var itemMaxLevel:Array<Int> = [99, 10, 10, 10, 10, 10, 4, 10, 10, 3];
		
	public static function getCost(id:Int):Int {
		return Math.round((itemLevel[id] + 1) * ((itemLevel[id] + 1) / 2) * 50);
	}
	
	public static function isUpgradable(id:Int) {
		return money >= getCost(id) && itemLevel[id] < itemMaxLevel[id];
	}
	
	public static function upgrade(id:Int):Void {
		var cost = getCost(id);
		if (money >= cost) {
			money -= cost;
			itemLevel[id]++;
		}
	}
	
	public static function update():Void {
		startingLives = 1 + itemLevel[0];
		
		shootDelay = (15 - Math.floor(itemLevel[1] / 2) * 2) * 2;
		bulletsPerShot = Math.ceil(itemLevel[1] / 2);
		middleBulletIndex = Math.floor(bulletsPerShot / 2);
		
		webDuration = 50 + itemLevel[2] * 20;
		lightningDMG = 0.25 + itemLevel[3] / 20;
		
		gemDropFactor = 1 + itemLevel[4] / 5;
		
		minionSpawnDelay = 350 - itemLevel[5] * 20;
		minionStartingLives = 1 + itemLevel[6];
		minionShootDelay = 25 - itemLevel[7];
		minionLightningChance = itemLevel[8] * 5;
		
		gemCollectionDistance = 100 + itemLevel[9] * 100;
		
		#if (!cap_30 || debug)
		shootDelay *= 2;
		minionSpawnDelay *= 2;
		minionShootDelay *= 2;
		lightningDMG /= 2;
		#end
	}
	
}
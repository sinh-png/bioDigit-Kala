package ui;

import kala.behaviors.collision.transformable.shapes.CollisionPolygon;
import kala.objects.sprite.ButtonSprite;
import kala.objects.sprite.Sprite.SpriteData;
import kha.FastFloat;

class Button extends ButtonSprite {

	public var mask:CollisionPolygon;
	
	public function new(data:Dynamic, spriteData:SpriteData, centerX:Bool = false, centerY:Bool = false) {
		super();
		this.data = data;
		loadSpriteData(spriteData);
		centerOrigin(centerX, centerY);
		mask = addObjectRectMask();
	}
	
}
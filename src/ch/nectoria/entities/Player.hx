package ch.nectoria.entities;

import ch.nectoria.entities.Physics;
import ch.nectoria.NP;
import ch.nectoria.scenes.FightScene;
import ch.nectoria.scenes.GameScene;
import ch.nectoria.scenes.SplashScene;
import flash.geom.Point;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Text;
import com.haxepunk.masks.Masklist;
import com.haxepunk.masks.Hitbox;

/**
 * ...
 * @author Bianchi Alexandre

 */
class Player extends Physics
{
	private var spPlayer:Spritemap;
	private var actionSign:Spritemap;
	public var speed:Float = 1.0;
	public var jumpSpeed:Float = 7.0;
	public var climbing:Bool = false;
	public var hasKey:Bool = false;
	public var swordHitbox:Hitbox;
	private var text:Text;
	private var message:String;

	public function new(pos:Point, flip:Bool = false) 
	{
		super(pos.x, pos.y);
		//Debug functions
		
		//Animations & Graphics
		spPlayer = new Spritemap("graphics/entity/player32.png", 16, 32);
		spPlayer.add("idle", [8], 0, false);
		spPlayer.add("walk", [0, 1, 2, 3, 4, 5, 6, 7], 10, true);
		spPlayer.add("jump", [1], 0, false);
		spPlayer.add("fall", [3], 0, false);
		spPlayer.add("hurt", [4], 0, false);
		
		//Action Mark
		actionSign = new Spritemap("graphics/tilemap.png", 16, 16);
		actionSign.add("actionSign", [241], 0, false);
		actionSign.play("actionSign");
		actionSign.y = -10; 
		
		graphic = new Graphiclist( );
		cast( graphic, Graphiclist ).add( spPlayer );
		cast( graphic, Graphiclist ).add( actionSign );
		
		spPlayer.flipped = flip;
		
		setHitbox(8, 23, -4, -9);
		type = "player";
		layer = 3;
	}
	
	override public function update():Void {
		var n:Entity = collide("npc", x, y);
		var s:Entity = collide("sign", x, y);
		var c:Entity = collide("chest", x, y);
		var d:Entity = collide("door", x, y);
		
		if (s != null || n !=null || c !=null || d !=null)
		{
			actionSign.visible = true;
		} else {
			actionSign.visible = false;
		}
		
		if (vx != 0) {
			spPlayer.play("walk");
		} else if (vy > 1) {
			spPlayer.play("fall");
		} else if (vy < -1) {
			spPlayer.play("jump");
		} else {
			spPlayer.play("idle");
		}
		
		if (!NP.frozenPlayer) {
			handleInput();
		}
		super.update();
	}
	
	public function handleInput():Void {
		if( (Input.check(Key.UP) || Input.check(Key.W)) && !inAir && collideBelow)
		{
			this.jump();
		}
		if( (Input.check(Key.LEFT) || Input.check(Key.A)) && !collideLeft)
		{
			this.moveLeft();
		}
		if( (Input.check(Key.RIGHT) || Input.check(Key.D)) && !collideRight)
		{
			this.moveRight();
		}
		if ( Input.pressed(Key.NUMPAD_8))
		{
			gainHealth();
		}
		if ( Input.pressed(Key.NUMPAD_7))
		{
			looseHealth();
		}
	}
	
	public function jump():Void
	{
		vy -= jumpSpeed;
		inAir = true;
	}
	public function moveLeft():Void
	{
		vx -= speed;
		if(collideRight)
		{
			collideRight = false;
		}
		spPlayer.flipped = true;
	}
	public function moveRight():Void
	{
		vx += speed;
		if(collideLeft)
		{
			collideLeft = false;
		}
		spPlayer.flipped = false;
	}
	
	public function gainHealth():Void {
		if (NP.currentPlayerHealth < NP.maxPlayerHealth) {
			NP.currentPlayerHealth++;
		}
	}
	
	public function looseHealth():Void {
		if (NP.currentPlayerHealth > 1) {
			NP.currentPlayerHealth--;
		} else {
			this.kill();
		}
	}
	
	public function kill():Void {
		NP.deadPlayer = true;
		scene.remove(this);
	}
}
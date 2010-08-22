package net.noiseinstitute.ld18
{
	import org.flixel.*;
	
	public class Ship extends LD18Sprite
	{
		private static const DEGREES_TO_RADIANS:Number = Math.PI / 180;
		private static const RATE_OF_FIRE:uint = 10;
		private static const DEATH_TIME:uint = 100;
		private static const FLICKER_DURATION:Number = 3;
		private static const SPLOSION_PARTICLES:Number = 12;
		private static const NUM_LIVES:Number = 2;
		private static const THRUST:Number = 7;
		
		private var splosion:FlxEmitter;
		
		public var lives:Number;
		
		[Embed(source="ship.png")] public static const ShipGraphic:Class; 

		private var lastFired:uint;
		private var dieTick:uint;
		
		public function Ship()
		{
			super(0, 0, ShipGraphic);
			lives = NUM_LIVES;
			centreX = 0;
			centreY = 0;
			antialiasing = true;
			lastFired = 0;
		}
		
		override public function render():void {
			if(dead) return;
			super.render();
		}
		
		override public function update():void {			
			var s:PlayState = PlayState(FlxG.state);

			if(dead) {
				if(s.tick > dieTick + DEATH_TIME) {
					respawn();
				} else {
					return;	
				}
			}
			
			// Turn
			if (FlxG.keys.LEFT) {
				angle -= 4;
			} else if(FlxG.keys.RIGHT) {
				angle += 4;
			}
			
			// Move
			if(FlxG.keys.UP) {
				velocity.x += THRUST * Math.sin(angle * DEGREES_TO_RADIANS);
				velocity.y -= THRUST * Math.cos(angle * DEGREES_TO_RADIANS);
			} else if(FlxG.keys.DOWN) {
				velocity.x -= THRUST * Math.sin(angle * DEGREES_TO_RADIANS);
				velocity.y += THRUST * Math.cos(angle * DEGREES_TO_RADIANS);
			}
			
			// Shoot
			if(FlxG.keys.X) {
				fire();
			}
			
			super.update();
		}
		
		override public function kill():void {
			if(dead || flickering()) return;
			
			// We are now dead
			dead = true;
			lives--;
			
			// Come to a dead stop
			velocity.x = 0;
			velocity.y = 0;
			
			// Asplode
			asplode();
			
			// Kill the ship, but keep it in existence
			super.kill();
			exists = true;
			
			// Save the tick on which we died
			var s:PlayState = PlayState(FlxG.state);
			dieTick = s.tick;
		}
		
		private function asplode():void {
			Game.sound.shipDie.playCachedMutation(4);
			
			// Set up the asplosion
			splosion = new FlxEmitter(0,0); 
			splosion.gravity = 0;
			splosion.particleDrag.x = 50;
			splosion.particleDrag.y = 50;
			splosion.delay = 1;
			splosion.width = width;
			splosion.height = height;
			
			for(var i:Number = 0; i < SPLOSION_PARTICLES; i++) {
				var particle:FlxSprite = new FlxSprite();
				particle.createGraphic(2, 2, 0xffffffff);
				splosion.add(particle);
			}
			
			var s:PlayState = PlayState(FlxG.state);
			s.splosions.add(splosion);
			
			splosion.x = x;
			splosion.y = y;
			splosion.start();
		}
		
		public function respawn():void {
			if(lives > 0) {
				dead = false;
				flicker(FLICKER_DURATION);
				x = 0;
				y = 0;
				angle = 0;
			}
		}
		
		public function fire():void {
			var s:PlayState = PlayState(FlxG.state);

			// Only fire a bullet if enough ticks have passed
			if(s.tick >= lastFired + RATE_OF_FIRE) {
				Game.sound.shipShoot.playCachedMutation(4);
				s.bullets.add(new Bullet(centreX, centreY, angle, velocity));
				lastFired = s.tick;
			}
		}
	}
}
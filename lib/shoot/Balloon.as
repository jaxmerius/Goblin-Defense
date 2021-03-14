package lib.shoot {
	
	import flash.display.MovieClip;
	import lib.shoot.Particle;
	import flash.events.Event;
	
	public class Balloon extends Particle {
		
		public var sinMeter:Number;
		public var bobValue:Number;
		public var status:String;
		
		public function Balloon() {			
			status = "OK";
			bobValue = 0.1;
			sinMeter = 0;
			xVel = 0;
			yVel = 0;
			airResistance = 1;
			gravity = 0;
			gotoAndPlay(1);
		}
		
		public function destroy():void {
			gotoAndStop(29);
			gravity = 0.75;
			if (status == "Jumper") {
				dispatchEvent(new Event(Particle.BARRAGE, true, false));
			}
			status = "Dead";
		}
		
		public override function update():void {
			if (status == "Jumper") {
				yVel = Math.sin(sinMeter) * bobValue;
			}
			
			if (y >= 483) {
				bobValue = -1;
			} else {
				bobValue = 1;
			}
			
			sinMeter += 0.1;
			
			super.update();
			
			if (x < 125) {
				status = "Escaped";
				trace(status);
				dispatchEvent(new Event(Particle.PURGE_EVENT, true, false));
				dispatchEvent(new Event(Particle.LOSE_LIFE, true, false));
			}
		}
	}
}
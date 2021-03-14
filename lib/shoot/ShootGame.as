package lib.shoot {
	import flash.display.MovieClip
	import lib.shoot.Particle;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.text.*;
	import com.greensock.TweenLite;
	import com.greensock.plugins.*;
	
	public class ShootGame extends MovieClip {
		public static const DEAD:String = "DEAD";
		
		private var background:MovieClip;
		private var tint:MovieClip;
		private var ground:MovieClip;
		private var tower:MovieClip;
		private var hero:MovieClip;
		private var arm:MovieClip;
		
		private var arrows:Array;
		private var balloons:Array;
		
		private var isArrow:Number;
		
		private var towerLocation:Point;
		private var bowLocation:Point;
		
		private var bowAngle:Number;
		
		private var scoreText:TextField;
		private var textFormat:TextFormat;
		private var score:uint = 0;
		
		private var lifeText:TextField;
		private var life:uint = 3;
		
		private var arrowsLayer:Sprite;
		private var balloonsLayer:Sprite;
		private var touchLayer:Sprite;
		
		private var balloonSpawnDelay:Number;
		private var balloonSpawnCounter:Number;
		
		private var difficulty:Number;
		private var difficultyRate:Number;
		private var difficultyCounter:Number;
		
		private var jumpNum:Number;
		private var sprintNum:Number;
		
		private var isBarrage:Number;
		private var canBarrage:Number;
		private var barrageCount:Number;
		private var barrageSpacing:Number;
		private var barrageText:TextField;
		
		private var instructionText:TextField;
		
		public function ShootGame() {
			canBarrage = 0;
			barrageCount = 10;
			barrageSpacing = 10;
			
			difficultyRate = 0.5;
			difficulty = 1;
			difficultyCounter = 0;
			balloonSpawnDelay = balloonSpawnCounter = 100;
			
			tint = new ScreenTint();
			background = new Background();
			ground = new Ground();
			tower = new Tower();
			
			scoreText = new TextField();
			scoreText.x = 125;
			scoreText.y = 15;
			scoreText.width = 75;
			
			lifeText = new TextField();
			lifeText.x = 290;
			lifeText.y = 15;
			lifeText.width = 75;
			
			barrageText = new TextField();
			barrageText.x = 499;
			barrageText.y = 15;
			barrageText.width = 75;
			
			instructionText = new TextField();
			instructionText.x = 400;
			instructionText.y = 300;
			instructionText.width = 500;
			
			textFormat = new TextFormat();
			textFormat.color = 0x000000;
			textFormat.size = 24;
			textFormat.align = "right";
			textFormat.font = "Showcard Gothic";

			scoreText.defaultTextFormat = textFormat;
			scoreText.setTextFormat(textFormat);
			
			lifeText.defaultTextFormat = textFormat;
			lifeText.setTextFormat(textFormat);
			
			barrageText.defaultTextFormat = textFormat;
			barrageText.setTextFormat(textFormat);
			
			instructionText.defaultTextFormat = textFormat;
			instructionText.setTextFormat(textFormat);
			
			scoreText.text = score.toString();
			
			lifeText.text = life.toString();
			
			barrageText.text = canBarrage.toString();
			
			instructionText.text = "Click to shoot, press space to barrage.";
			
			isArrow = 0;
			
			arrows = new Array();
			balloons = new Array();
			
			hero = new Hero();
			arm = new Arm();
			
			bowLocation = new Point(120, 270);
			towerLocation = new Point(125, 415);
			bowAngle = 0;
			
			tower.x = towerLocation.x;
			tower.y = towerLocation.y;
			
			hero.x = 160;
			hero.y = 290;
			
			arm.x = bowLocation.x;
			arm.y = bowLocation.y;
			
			addChild(background);
			addChild(ground);
			addChild(hero);
			addChild(tower);
			
			addChild(scoreText);
			addChild(lifeText);
			addChild(barrageText);
			addChild(instructionText);

			addChild(arm);
			
			addEventListener(Event.ENTER_FRAME, update);
			
			arrowsLayer = new Sprite();
			balloonsLayer = new Sprite();
			touchLayer = new Sprite();
			
			addChild(arrowsLayer);
			addChild(balloonsLayer);
			addChild(tint);
			addChild(touchLayer);
			addEventListener(Event.ADDED_TO_STAGE, setupTouchLayer);
			touchLayer.addEventListener(MouseEvent.CLICK, shootArrow);
			
			TweenPlugin.activate([TintPlugin]);
			TweenLite.to(tint, 0, {tint:0xff0000, alpha:0});
		}
		
		private function setupTouchLayer(evt:Event):void {
			touchLayer.graphics.beginFill(0x000000, 0);
			touchLayer.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			touchLayer.graphics.endFill();
			stage.addEventListener(KeyboardEvent.KEY_DOWN, shootArrowBarrage);
			stage.addEventListener(Particle.BARRAGE, addBarrage);
		}
		
		private function shootArrow(evt:MouseEvent):void {
			makeArrow(bowAngle);
		}
		
		private function shootArrowBarrage(evt:KeyboardEvent):void {
			if (evt.keyCode == Keyboard.SPACE && canBarrage > 0) {
				canBarrage --;
				
				barrageText.text = canBarrage.toString();
				
				isBarrage = 1;
				
				var i:int;
				
				for (i = 0; i < barrageCount; i++) {
					makeBarrage(bowAngle - ((barrageCount - i - (barrageCount / 2)) * barrageSpacing));
				}
				
				isBarrage = 0;
				
			}
		}
		
		private function addBarrage(String):void {
			canBarrage++;
			barrageText.text = canBarrage.toString();
		}
		
		private function makeArrow(angle:Number):void {
			if (isArrow != 1) {
				var newArrow:Particle = new Arrow();
				
				newArrow.x = arm.x + 10;
				newArrow.y = arm.y + 15;
				newArrow.rotation = angle;
				
				var xDiff:Number = bowLocation.x - touchLayer.mouseX;
				var yDiff:Number = bowLocation.y - touchLayer.mouseY;
				
				var distance:Number = Math.sqrt(Math.pow(xDiff, 2) + Math.pow(yDiff, 2));
				
				var power:Number = distance / 15;
				
				newArrow.xVel = power * Math.cos(newArrow.rotation / 180 * Math.PI);
				newArrow.yVel = power * Math.sin(newArrow.rotation / 180 * Math.PI);
				
				newArrow.addEventListener(Particle.PURGE_EVENT, purgeArrowHandler);
				
				arrowsLayer.addChild(newArrow);
				arrows.push(newArrow);
				
				isArrow = 1;
			}
		}
		
		private function makeBarrage(angle:Number):void {
			var newArrow:MovieClip = new Arrow();
				
			newArrow.x = Math.random() * 1000;
			newArrow.y = 0;
			
			newArrow.addEventListener(Particle.PURGE_EVENT, purgeArrowHandler);
				
			arrowsLayer.addChild(newArrow);
			arrows.push(newArrow);
		}
		
		private function makeBalloons():void {
			balloonSpawnCounter++;
			
			if (balloonSpawnCounter%(80 - (difficulty * 4)) == 0) {
				makeBalloon();
			}
		}
		
		private function makeBalloon():void {
			difficultyCounter++;
			
			jumpNum = Math.ceil(Math.random() * 4);
			sprintNum = Math.ceil(Math.random() * 4);
			
			var newBalloon:Balloon = new MouseBalloon();
				
			newBalloon.x = 1150;
			newBalloon.y = 483;
				
			newBalloon.xVel = (-1 * difficulty);
			
			if (newBalloon.xVel%2 == 0 && jumpNum == 3) {
				newBalloon.status = "Jumper";
			} else if (newBalloon.xVel%1.5 == 0 && sprintNum == 3) {
				newBalloon.xVel -= 1;
			}
			
			trace("Goblin Velocity: ",newBalloon.xVel);
				
			newBalloon.addEventListener(Particle.PURGE_EVENT, purgeBalloonHandler);
			newBalloon.addEventListener(Particle.LOSE_LIFE, loseLife);
				
			balloonsLayer.addChild(newBalloon);
			balloons.push(newBalloon);
			
			if (difficultyCounter%10 == 0) {
				difficulty += difficultyRate;
			}
		}
		
		private function purgeArrowHandler(evt:Event):void {
			var targetArrow:Particle = Particle(evt.target);
			purgeArrow(targetArrow);
		}
		
		private function purgeBalloonHandler(evt:Event):void {
			var targetBalloon:Particle = Particle(evt.target);
			purgeBalloon(targetBalloon);
		}
		
		private function loseLife(evt:Event):void {
			life--;
			lifeText.text = life.toString();
			if (life == 2) {
				TweenPlugin.activate([TintPlugin]);
				TweenLite.to(tint, 2, {tint:0xff0000, alpha:0.25});
				trace("Red 1");
			} else if (life == 1) {
				TweenPlugin.activate([TintPlugin]);
				TweenLite.to(tint, 2, {tint:0xff0000, alpha:0.40});
				trace("Red 2");
			}
		}
		
		private function purgeBalloon(targetBalloon:Particle):void {
			targetBalloon.removeEventListener(Particle.PURGE_EVENT, purgeBalloonHandler);
			try {
				var i:int;
				for (i = 0; i < balloons.length; i++) {
					if (balloons[i].name == targetBalloon.name) {
						balloons.splice(i, 1);
						balloonsLayer.removeChild(targetBalloon);
						i = balloons.length;
					}
				}
			}
			catch(e:Error) {
				trace("Failed to delete balloon!", e);
			}
		}
		
		private function purgeArrow(targetArrow:Particle):void {
			targetArrow.removeEventListener(Particle.PURGE_EVENT, purgeArrowHandler);
			try {
				var i:int;
				for (i = 0; i < arrows.length; i++) {
					if (arrows[i].name == targetArrow.name) {
						arrows.splice(i, 1);
						arrowsLayer.removeChild(targetArrow);
						i = arrows.length;
					}
				}
				isArrow = 0;
			}
			catch(e:Error) {
				trace("Failed to delete arrow!", e);
			}
		}
		
		private function hitTest(arrow:Particle):void {
			for each (var balloon:Balloon in balloons) {
				if (balloon.status != "Dead" && balloon.hitTestPoint(arrow.x, arrow.y)) {
					balloon.destroy();
					purgeArrow(arrow);
					score += 1;
					scoreText.text = score.toString();
					TweenPlugin.activate([TintPlugin]);
					TweenLite.to(instructionText, 2, {tint:0xff0000, alpha:0});
				}
			}
		}
		
		private function update(evt:Event):void {
			var target:Point = new Point(stage.mouseX, stage.mouseY);
			
			var angleRad:Number = Math.atan2(target.y - bowLocation.y, target.x - bowLocation.x);
			
			bowAngle = angleRad * 180 / Math.PI;
			
			arm.rotation = bowAngle;
			
			for each (var balloon:Particle in balloons) {
				balloon.update();
			}
			
			for each (var arrow:Particle in arrows) {
				arrow.update();
				hitTest(arrow);
			}
			
			if (life < 1) {
				dispatchEvent(new Event(ShootGame.DEAD, true, false));
			}
			
			makeBalloons();
		}
	}
}
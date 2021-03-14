package lib.shoot {
	
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.MovieClip;
	import lib.shoot.ShootGame;
	
	public class ShootDoc extends MovieClip {
		
		public function ShootDoc() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			createIntro();
		}
		
		private function createIntro():void {
			var intro:IntroScreen = new IntroScreen();
			var intro2:Intro = new Intro();
			
			addChild(intro);
			
			intro.addEventListener(Event.ENTER_FRAME, checkFrame);
			
			function checkFrame(evt:Event):void {
				if(intro2.currentFrame == 482) {
					removeChild(intro);
					evt.currentTarget.removeEventListener(Event.ENTER_FRAME, checkFrame);
					createStartMenu();
				}
			}
		}
		
		private function createStartMenu():void {
			var startMenu:StartScreen = new StartScreen();
			
			addChild(startMenu);
			
			startMenu.startButton.addEventListener(MouseEvent.CLICK, startGameHandler);
		}
		
		private function startGameHandler(evt:MouseEvent):void {
			removeChild(evt.currentTarget.parent);
			
			evt.currentTarget.removeEventListener(MouseEvent.CLICK, startGameHandler);
			
			createGame();
		}
		
		private function createGame():void {
			var game:ShootGame = new ShootGame();
			
			addChild(game);
	
			addEventListener(ShootGame.DEAD, endGame);
			
			function endGame():void {
				removeEventListener(ShootGame.DEAD, endGame);
				
				removeChild(game);
				
				var endScreen:EndScreen = new EndScreen();
				
				addChild(endScreen);
			}
		}
	}
}
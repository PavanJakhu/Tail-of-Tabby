package  {
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flashx.textLayout.formats.BackgroundColor;
	import flash.geom.Rectangle;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	import fl.transitions.TweenEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class Game extends MovieClip {
		var menu:int; //Which screen the game is at
		var started:Boolean = false;
		
		//Main menu
		var playBtn:PlayBtn;
		var optionsBtn:OptionsBtn;
		var titleScreen:MovieClip;
		
		//Options menu
		var vol:Vol;
		var backBtn:BackBtn;
		var volUp:VolUp;
		var volDown:VolDown;
		var volLevel:VolLevel;
		var volLevelText:int;
		
		//Pause menu
		var pauseBG:MovieClip;
		var resumeBtn:SimpleButton;
		var exitBtn:SimpleButton;
		
		//Sounds
		var startMusic:Sound = new Sound();
		var startLength:Number;
		var inGameMusic:Sound = new Sound();
		var inGameLength:Number;
		var startMusicChannel:SoundChannel = new SoundChannel();
		var inGameMusicChannel:SoundChannel = new SoundChannel();
		var volumeLevel:SoundTransform = new SoundTransform();
		
		//In game
		public static var mainChar:MovieClip;
		public static var enemyArr:Array;
		var floorMC:MovieClip;
		var enemyHit:int;
		var healthBar:MovieClip;
		var healthOldScale:Number = 1;
		var healthNewScale:Number = 0.9;
		var manaBar:MovieClip;
		var manaOldScale:Number = 1;
		var manaNewScale:Number = 0.9;
		var expBar:MovieClip;
		var expOldScale:Number = 0;
		var expNewScale:Number = 10;
		var firstAch:Boolean = false;
		var achievement:MovieClip;
		var delay:Timer;
		
		public function Game() 
		{
			if (!stage) //if stage doesn't exist.
			{
				this.addEventListener(Event.ADDED_TO_STAGE, Init, false, 0, true);
			}
			else
			{
				Init();
			}
		}
		
		private function Init(e:Event = null):void
		{
			stage.dispatchEvent(new Event("INIT"));
			if (!started)
			{
				menu = 0;
				started = true;
			}
			else
				menu = 1;
			speed = 20;
			enemyArr = new Array(50);
			achievement = new Achievement();
			volLevelText = 5;
			AddCharacters();
			startMusic.load(new URLRequest("Music/MeadowOfThePast.mp3"));
			inGameMusic.load(new URLRequest("Music/CloudTopLoops.mp3"));
			volumeLevel = new SoundTransform();
			volumeLevel.volume = volLevelText / 10;
			this.addEventListener(Event.ENTER_FRAME, Update, false, 0, true);
		}
		
		private function onStartMusicComplete():void
		{
			inGameMusicChannel.stop();
			startMusicChannel = startMusic.play();
			startMusicChannel.soundTransform = volumeLevel;
		}
		
		private function onInGameMusicComplete():void
		{
			startMusicChannel.stop();
			inGameMusicChannel = inGameMusic.play();
			inGameMusicChannel.soundTransform = volumeLevel;
		}
		
		private function updateSound(e:Event):void
		{
			if (startMusicChannel.position >= startMusic.length)
				startMusicChannel = startMusic.play();
		}
		
		private function AddCharacters()
		{
			titleScreen = new TitleScreen();
			
			healthBar = new HealthBar();
			healthBar.x = stage.stageWidth / 33;
			healthBar.y = stage.stageHeight / 40;
			
			manaBar = new ManaBar();
			manaBar.x = healthBar.x;
			manaBar.y = healthBar.y + healthBar.height + 10;
			
			expBar = new ExpBar();
			expBar.x = manaBar.x;
			expBar.y = manaBar.y + manaBar.height + 10;
			
			floorMC = new FloorMC();
			
			mainChar = new MCharacterFront();
			mainChar.x = 7000 / 2 - mainChar.width / 2;
			mainChar.y = 4900 / 2 - mainChar.height / 2;
			
			var enemy:MovieClip;
			for (var i:int = 0; i < enemyArr.length; i++)
			{
				enemy = new ECharacter();
				enemy.x = Randomize(0,7000 - enemy.width);
				enemy.y = Randomize(0,4900 - enemy.height);
				for (var j:int = 0; j < enemyArr.length; j++)
				{
					if (enemyArr[j] != null && CheckCollision(enemy, enemyArr[j]))
					{
						enemy.x = Randomize(0,7000 - enemy.width);
						enemy.y = Randomize(0,4900 - enemy.height);
						j = 0;
					}
				}
				Game.enemyArr[i] = enemy;
			}
		}
		
		private function Update(e:Event):void
		{
			switch (menu)
			{
				case 0: //Main menu
					this.removeEventListener(Event.ENTER_FRAME, Update, false);
					stage.dispatchEvent(new Event("STOP_CAMERA_X"));
					stage.dispatchEvent(new Event("STOP_CAMERA_Y"));
					onStartMusicComplete();
					
					playBtn = new PlayBtn();
					optionsBtn = new OptionsBtn();
					
					playBtn.x = stage.stageWidth / 2;
					playBtn.y = stage.stageHeight / 2 + 10;
					optionsBtn.x = stage.stageWidth / 2;
					optionsBtn.y = playBtn.y + 100;
					
					stage.addChild(titleScreen);
					stage.addChild(playBtn);
					stage.addChild(optionsBtn);
					
					this.addEventListener(Event.ENTER_FRAME, updateSound, false, 0, true);
					playBtn.addEventListener(MouseEvent.CLICK, onGameClick, false, 0, true);
					optionsBtn.addEventListener(MouseEvent.CLICK, onOptionsClick, false, 0, true);
					break;
				case 1: //In game
					this.addChild(floorMC);
					stage.addChild(healthBar);
					stage.addChild(manaBar);
					stage.addChild(expBar);
					this.addChild(mainChar);
					for	(var i:int = 0; i < enemyArr.length; i++)
						this.addChild(enemyArr[i]);
					
					if (mainChar.x <= 512 || mainChar.x >= 6488 - mainChar.width)
						stage.dispatchEvent(new Event("STOP_CAMERA_X"));
					else
						stage.dispatchEvent(new Event("MOVE_CAMERA_X"));
					if (mainChar.y <= 384 || mainChar.y >= 4516 - mainChar.height)
						stage.dispatchEvent(new Event("STOP_CAMERA_Y"));
					else
						stage.dispatchEvent(new Event("MOVE_CAMERA_Y"));
					
					/*if (inGameMusicChannel.position >= inGameMusic.length)
						inGameMusicChannel = inGameMusic.play();*/
					
					for (i = 0; i < enemyArr.length; i++)
					{
						if (CheckCollision(enemyArr[i], mainChar))
						{
							stage.removeChild(healthBar);
							stage.removeChild(manaBar);
							stage.removeChild(expBar);
							this.removeEventListener(Event.ENTER_FRAME, Update, false);
							enemyHit = i;
							this.dispatchEvent(new Event("BATTLE"));
							break;
						}
					}
					this.addEventListener("VICTORY", onVictory, false, 0, true);
					this.addEventListener("DEFEAT", onDefeat, false, 0, true);
					stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardDown, false, 0, true);
					break;
				case 2: //Pause
					this.removeEventListener(Event.ENTER_FRAME, Update, false);
					stage.dispatchEvent(new Event("STOP_CAMERA_X"));
					stage.dispatchEvent(new Event("STOP_CAMERA_Y"));
					
					pauseBG = new PauseBG();
					resumeBtn = new ResumeBtn();
					exitBtn = new ExitBtn();
					
					pauseBG.x = 125;
					pauseBG.y = 139;
					resumeBtn.x = stage.stageWidth / 2;
					resumeBtn.y = stage.stageHeight / 3;
					optionsBtn.x = stage.stageWidth / 2;
					optionsBtn.y = resumeBtn.y + 100;
					exitBtn.x = stage.stageWidth / 2;
					exitBtn.y = optionsBtn.y + 100;
					
					stage.addChild(pauseBG);
					stage.addChild(resumeBtn);
					stage.addChild(optionsBtn);
					stage.addChild(exitBtn);
					
					resumeBtn.addEventListener(MouseEvent.CLICK, onGameClick, false, 0, true);
					optionsBtn.addEventListener(MouseEvent.CLICK, onOptionsClick, false, 0, true);
					exitBtn.addEventListener(MouseEvent.CLICK, onExitClick, false, 0, true);
					break;
				default:
					trace(menu);
					break;
			}
		}
		
		private function onGameClick(e:MouseEvent):void{
			if (menu == 0)
			{
				stage.removeChild(playBtn);
				stage.removeChild(titleScreen);
				AddCharacters();
				onInGameMusicComplete();
			}
			else
			{
				stage.removeChild(pauseBG);
				stage.removeChild(resumeBtn);
				stage.removeChild(exitBtn);
			}
			playBtn.removeEventListener(MouseEvent.CLICK, onGameClick, false);
			optionsBtn.removeEventListener(MouseEvent.CLICK, onOptionsClick, false);
			this.addEventListener(Event.ENTER_FRAME, Update, false, 0, true);
			stage.dispatchEvent(new Event("MOVE_CAMERA"));
			stage.removeChild(optionsBtn);
			menu = 1;
		}
		
		private function onOptionsClick(e:MouseEvent):void
		{
			optionsBtn.removeEventListener(MouseEvent.CLICK, onOptionsClick, false);
			if (menu == 0)
			{
				stage.removeChild(playBtn);
				stage.removeChild(optionsBtn);
			}
			else if (menu == 2)
			{
				stage.removeChild(resumeBtn);
				stage.removeChild(optionsBtn);
				stage.removeChild(exitBtn);
			}
			
			backBtn = new BackBtn();
			vol = new Vol();
			volUp = new VolUp();
			volDown = new VolDown();
			volLevel = new VolLevel();
			
			backBtn.x = stage.stageWidth / 2;
			backBtn.y = stage.stageHeight / 2 + 100;
			vol.x = stage.stageWidth / 4;
			vol.y = stage.stageHeight / 3;
			volDown.x = vol.x + vol.width + 100;
			volDown.y = stage.stageHeight / 3;
			volLevel.x = volDown.x + volDown.width + 10;
			volLevel.y = stage.stageHeight / 3;
			volUp.x = volLevel.x + volLevel.width + 10;
			volUp.y = stage.stageHeight / 3;
			
			stage.addChild(backBtn);
			stage.addChild(vol);
			stage.addChild(volDown);
			stage.addChild(volUp);
			stage.addChild(volLevel);
			
			backBtn.addEventListener(MouseEvent.CLICK, onBackClick, false, 0, true);
			volDown.addEventListener(MouseEvent.CLICK, onVolDownClick, false, 0, true);
			volUp.addEventListener(MouseEvent.CLICK, onVolUpClick, false, 0, true);
		}
		
		private function onVolDownClick(e:MouseEvent):void
		{
			if (volLevelText == 0)
				volLevelText = 0;
			else
				volLevelText--;
			volumeLevel.volume = volLevelText / 10;
			startMusicChannel.soundTransform = volumeLevel;
			inGameMusicChannel.soundTransform = volumeLevel;
			volLevel.LevelText.text = "" + volLevelText;
		}
		
		private function onVolUpClick(e:MouseEvent):void
		{
			if (volLevelText == 10)
				volLevelText = 10;
			else
				volLevelText++;
			volumeLevel.volume = volLevelText / 10;
			startMusicChannel.soundTransform = volumeLevel;
			inGameMusicChannel.soundTransform = volumeLevel;
			volLevel.LevelText.text = "" + volLevelText;
		}
		
		private function onExitClick(e:MouseEvent):void{
			resumeBtn.removeEventListener(MouseEvent.CLICK, onGameClick, false);
			optionsBtn.removeEventListener(MouseEvent.CLICK, onOptionsClick, false);
			exitBtn.removeEventListener(MouseEvent.CLICK, onExitClick, false);
			this.addEventListener(Event.ENTER_FRAME, Update, false, 0, true);
			stage.removeChild(pauseBG);
			stage.removeChild(resumeBtn);
			stage.removeChild(optionsBtn);
			stage.removeChild(exitBtn);
			
			stage.removeChild(healthBar);
			stage.removeChild(manaBar);
			this.removeChild(mainChar);
			for (var i:int = 0; i < enemyArr.length; i++)
				this.removeChild(enemyArr[i]);
			menu = 0;
		}
		
		private function onBackClick(e:MouseEvent):void{
			stage.removeChild(vol);
			stage.removeChild(backBtn);
			stage.removeChild(volDown);
			stage.removeChild(volLevel);
			stage.removeChild(volUp);
			
			if (menu == 0)
				this.addEventListener(Event.ENTER_FRAME, Update, false, 0, true);
			else if (menu == 2)
			{
				stage.addChild(resumeBtn);
				stage.addChild(optionsBtn);
				stage.addChild(exitBtn);
			}
		}
		
		private function keyboardDown(e:KeyboardEvent):void
		{
			if (e.keyCode == 80)
				menu = 2;
		}
		
		private function onVictory(e:Event = null):void
		{
			this.removeChild(enemyArr[enemyHit]);
			enemyArr.splice(enemyHit, 1);
			
			manaOldScale = manaNewScale;
			var tween1:Tween = new Tween(manaBar.ManaBarFill, "scaleX", None.easeOut, manaOldScale, manaNewScale, 0.3, true);
			manaNewScale -= 0.1;
			if (manaNewScale < 0)
				manaNewScale = 0;
			
			expOldScale = expNewScale;
			var tween2:Tween = new Tween(expBar.ExpBarFill, "scaleX", None.easeOut, expOldScale, expNewScale, 0.3, true);
			expNewScale += 10;
			if (expNewScale >= 150)
			{
				expOldScale = 0;
				expNewScale = 10;
			}
			
			if (!firstAch)
			{
				achievement.x = stage.stageWidth / 2 - achievement.width / 2;
				achievement.y = stage.stageHeight - achievement.height - 10;
				stage.addChild(achievement);
				
				var tween3:Tween = new Tween(achievement, "alpha", None.easeInOut, 0, 1, 1, true);
				delay = new Timer(2000);
				delay.start();
				delay.addEventListener(TimerEvent.TIMER, tweenOut, false, 0, true);
				firstAch = true;
			}
			started = true;
			this.addEventListener(Event.ENTER_FRAME, Update, false, 0, true);
		}
		
		private function tweenOut(e:TimerEvent):void
		{
			var tween:Tween = new Tween(achievement, "alpha", None.easeInOut, 1, 0, 1, true);
			delay.stop();
		}
		
		private function onDefeat(e:Event = null):void
		{
			mainChar.x += 50;
			
			healthOldScale = healthNewScale;
			var tween5:Tween = new Tween(healthBar.HealthBarFill, "scaleX", None.easeOut, healthOldScale, healthNewScale, 0.3, true);
			healthNewScale -= 0.1;
			if (healthNewScale < 0)
				healthNewScale = 0;
				
			manaOldScale = manaNewScale;
			var tween6:Tween = new Tween(manaBar.ManaBarFill, "scaleX", None.easeOut, manaOldScale, manaNewScale, 0.3, true);
			manaNewScale -= 0.1;
			if (manaNewScale < 0)
				manaNewScale = 0;
			started = true;
			this.addEventListener(Event.ENTER_FRAME, Update, false, 0, true);
		}
		
		private function CheckCollision(obj1:DisplayObject, obj2:DisplayObject):Boolean
		{
			//check for collision between 2 display objects
			if (obj1.getBounds(this).intersects(obj2.getBounds(this)))
				return true;
			else
				return false;
		}
		
		private function Randomize(min:Number, max:Number):Number
		{
			return Math.random() * (max - min) + min;
		}
	}
}

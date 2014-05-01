package 
{
	import flash.display.MovieClip;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.events.ProgressEvent;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.net.URLLoader;
	import flash.display.DisplayObject;

	public class TailsOfTabby extends MovieClip
	{
		//Loading bar to show the progress visually
		var progressBar_mc:MovieClip = new progressBar();
		var progressTxt:MovieClip = new ProgressTxt();
		//loader object will load external swf file
		var GameLoader:Loader = new Loader();
		var BattleLoader:Loader = new Loader();

		var Game:DisplayObject;
		var Battle:DisplayObject;

		function TailsOfTabby():void
		{
			//OPEN fires when loading process starts
			GameLoader.contentLoaderInfo.addEventListener(Event.OPEN, onOpen);
			//PROGRESS carries info about number of bytes loaded;
			GameLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			//COMPLETE fires when process finishes;
			GameLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onGameComplete);
			//start loading of World.swf;
			GameLoader.load(new URLRequest("game.swf"));
		}

		function loadBattle():void
		{
			//OPEN fires when loading process starts
			BattleLoader.contentLoaderInfo.addEventListener(Event.OPEN, onOpen);
			//PROGRESS carries info about number of bytes loaded;
			BattleLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			//COMPLETE fires when process finishes;
			BattleLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBattleComplete);
			//start loading of Battle.swf;
			BattleLoader.load(new URLRequest("BattleScreen.swf"));
		}

		//loading started so add the text field on the stage
		function onOpen(e:Event):void
		{
			//Loading percentage to show the progress numerically
			progressTxt.x = stage.stageWidth / 2 - 50;
			progressTxt.y = (stage.stageHeight / 2) - 60;
			addChild(progressTxt);

			progressBar_mc.x = 115;
			progressBar_mc.y = stage.stageHeight / 2;
			addChild(progressBar_mc);
		}

		//update progress
		function onProgress(e:ProgressEvent):void
		{
			progressBar_mc.scaleX = e.bytesLoaded / e.bytesTotal;
			progressTxt.progress_txt.text = String(Math.floor((e.bytesLoaded/e.bytesTotal)*100) + "%");
		}

		//end of loading so clean up and add loaded clip on the stage
		function onGameComplete(e:Event):void
		{
			trace("Game loading process complete");
			//remove unnecessary listeners
			GameLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			GameLoader.contentLoaderInfo.removeEventListener(Event.OPEN, onOpen);
			GameLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onGameComplete);
			//remove text field and loading bar;
			removeChild(progressTxt);
			removeChild(progressBar_mc);
			//add loaded object
			Game = GameLoader.content;

			loadBattle();
		}

		function onBattleComplete(e:Event):void
		{
			trace("Battle loading process complete");
			//remove unnecessary listeners
			BattleLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			BattleLoader.contentLoaderInfo.removeEventListener(Event.OPEN, onOpen);
			BattleLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onBattleComplete);
			//remove text field and loading bar;
			removeChild(progressTxt);
			removeChild(progressBar_mc);
			//add loaded object
			Battle = BattleLoader.content;

			stage.addChild(Game);
			Game.addEventListener("BATTLE", onBattle);

			Battle.addEventListener("DEFEAT", onDefeat);
			Battle.addEventListener("VICTORY", onVictory);
		}

		function onBattle(e:Event):void
		{
			stage.removeChild(Game);
			stage.addChild(Battle);
		}

		function onDefeat(e:Event):void
		{
			stage.removeChild(Battle);
			stage.addChild(Game);
			Game.dispatchEvent(new Event("DEFEAT"));
		}

		function onVictory(e:Event):void
		{
			stage.removeChild(Battle);
			stage.addChild(Game);
			Game.dispatchEvent(new Event("VICTORY"));
		}
	}
}
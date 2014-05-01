//Project: Final Project - Tales of Tabby
//Coded by: Adam Gadal
//Last Modified: April 22th, 2014

package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	import fl.transitions.TweenEvent;
	import flash.ui.Mouse;
	
	public class Battle extends MovieClip {
		
		//VARIABLES AND OBJECTS
		var bg:MovieClip; //Background for the screen
		var battleUI:MovieClip; //Background for the Battle UI
		var playerCat:MovieClip; //Player object
		var player_Attack:MovieClip //Player Attack object
		var player_Block:MovieClip; //Player Block object
		var player_Charge:MovieClip; //Player Charge object
		var enemyDog:MovieClip; //Enemy object
		var enemy_Attack:MovieClip; //Enemy Attack object
		var enemy_Block:MovieClip; //Enemy Block object
		var enemy_Charge:MovieClip; //Enemy Charge object
		var moveTween:MovieClip; //Movement Tween for animations
		
		//Health & Health Bars
		var playerHealthBar:Sprite; //Player's Health Bar
		var playerHealthBorder:Sprite; //Border of the player's health bar
		var playerHealthText:TextField; //Player's health text
		var healthTooltip:TextField; //Tooltip for health
		var playerHealth:int; //Player's total health
		var playerCurrentHealth:int; //Player's current health
		var playerManaBar:Sprite; //Player's Mana Bar
		var playerManaBorder:Sprite; //Border of the player's mana bar
		var playerManaText:TextField; //Player's mana text
		var manaTooltip:TextField; //Tooltip for mana
		var playerMana:int; //Player's total mana
		var playerCurrentMana:int; //Player's current mana
		var enemyHealthBar:Sprite; //Enemy's Health Bar
		var enemyHealthBorder:Sprite; //Border of the enemy's health bar
		var enemyHealth:int; //Enemy's total health
		var enemyCurrentHealth:int; //Enemy's current health
		var enemyTooltip:TextField; //Tooltip for the enemy
		var playerOldScale:Number = 1;  //Scale for player health
		var playerNewScale:Number = 1; //Scale adjustment for player health
		var enemyOldScale:Number = 1; //Scale for enemy health
		var enemyNewScale:Number = 1; //Scale adjustment for player health
		
		//Attack Options
		var playerBlock:Boolean; //True if player is blocking, false if player is not blocking
		var enemyBlock:Boolean; //True if enemy is blocking, false if enemy is not blocking
		var playerCharge:Boolean; //True if player is charging, false if not
		var enemyCharge:Boolean; //True if enemy is charging, flase if not
		var playerAttack:Boolean; //True if player is attacking, false if not
		var playerAlive:Boolean; //Is the player alive?
		var enemyAlive:Boolean; //Is the enemy alive?
		
		//Player Buttons
		var attackBtn:Sprite; //Button for attacking
		var attackBtnBorder:Sprite; //Border for the attack button
		var attackText:TextField; //Text for the attack button
		var blockBtn:Sprite; //Button for blocking
		var blockBtnBorder:Sprite; //Border for the block button
		var blockText:TextField; //Text for the block button
		var chargeBtn:Sprite; //Button for charging
		var chargeBtnBorder:Sprite; //Border for the charge button
		var chargeText:TextField; //Text for the charge button
		
		//Animations
		var playerAttackTween:Tween;
		
		public function Battle() {
			if (!stage) //if stage doesn't exist.
				this.addEventListener(Event.ADDED_TO_STAGE, Init, false, 0, true);
			else
				Init();
		}//end Battle() function
		
		private function Init(e:Event = null)
		{
			bg = new FloorMC(); 
			bg.x = 0; bg.y = 0;
			this.addChild(bg);
			
			battleUI = new BattleMC(); 
			battleUI.x = 0; battleUI.y = stage.stageHeight - battleUI.height;
			this.addChild(battleUI);
			
			playerCat = new CatIdle();
			playerCat.x = stage.stageWidth / 4; 
			playerCat.y = stage.stageHeight / 2;
			playerCat.scaleX *= -1;
			stage.addChild(playerCat);
			player_Attack = new CatAttack();
			player_Attack.scaleX *= -1;
			player_Block = new CatDefend();
			player_Block.scaleX *= -1;
			player_Charge = new CatCharge();
			player_Charge.scaleX *= -1;
			
			enemyDog = new EnemyIdle();
			enemyDog.x = stage.stageWidth / 2 + 50; 
			enemyDog.y = stage.stageHeight / 2;
			stage.addChild(enemyDog);
			enemy_Attack = new EnemyAttack();
			enemy_Block = new EnemyDefend();
			enemy_Charge = new EnemyCharge();
			
			playerHealth = 100; //Sets the player's health
			playerCurrentHealth = playerHealth; //Sets the player's current health
			playerMana = 5; //Sets the player's mana
			playerCurrentMana = playerMana; //Sets the palyer's current mana
			enemyHealth = 50; //Sets the enemy's health
			enemyCurrentHealth = enemyHealth; //Sets the enemy's current health
			
			playerHealthBorder = new Sprite();
			playerHealthBorder.graphics.beginFill(0x000000);
			playerHealthBorder.graphics.drawRect(45, 545, 310, 60);
			playerHealthBorder.graphics.endFill();
			this.addChild(playerHealthBorder);
			playerHealthBar = new Sprite();
			playerHealthBar.graphics.beginFill(0x33FF33);
			playerHealthBar.graphics.drawRect(0, 0, 300, 50);
			playerHealthBar.graphics.endFill();
			playerHealthBar.x = 50;
			playerHealthBar.y = 550;
			this.addChild(playerHealthBar);
			playerHealthText = new TextField();
			playerHealthText.defaultTextFormat = new TextFormat('Impact', 30, 0xFFFFFF);
			playerHealthText.text = (playerHealth + "/" + playerHealth);
			playerHealthText.x = 150;
			playerHealthText.y = 555;
			playerHealthText.width = 100;
			this.addChild(playerHealthText);
			healthTooltip = new TextField();
			healthTooltip.defaultTextFormat = new TextFormat('Impact', 30, 0x000000);
			healthTooltip.text = ": HEALTH";
			healthTooltip.x = 360;
			healthTooltip.y = 550;
			this.addChild(healthTooltip);
			
			playerManaBorder = new Sprite();
			playerManaBorder.graphics.beginFill(0x000000);
			playerManaBorder.graphics.drawRect(45, 610, 310, 60);
			playerManaBorder.graphics.endFill();
			this.addChild(playerManaBorder);
			playerManaBar = new Sprite();
			playerManaBar.graphics.beginFill(0x66CCFF);
			playerManaBar.graphics.drawRect(0, 0, 300, 50);
			playerManaBar.graphics.endFill();
			playerManaBar.x = 50;
			playerManaBar.y = 615;
			this.addChild(playerManaBar);
			playerManaText = new TextField();
			playerManaText.defaultTextFormat = new TextFormat('Impact', 30, 0xFFFFFF);
			playerManaText.text = (playerCurrentMana + "/" + playerMana);
			playerManaText.x = 180;
			playerManaText.y = 620;
			this.addChild(playerManaText);
			manaTooltip = new TextField();
			manaTooltip.defaultTextFormat = new TextFormat('Impact', 30, 0x000000);
			manaTooltip.text = ": MANA";
			manaTooltip.x = 360;
			manaTooltip.y = 615;
			this.addChild(manaTooltip);
			
			enemyHealthBorder = new Sprite();
			enemyHealthBorder.graphics.beginFill(0x000000);
			enemyHealthBorder.graphics.drawRect(675, 545, 310, 60);
			enemyHealthBorder.graphics.endFill();
			this.addChild(enemyHealthBorder);
			enemyHealthBar = new Sprite();
			enemyHealthBar.graphics.beginFill(0x33FF33);
			enemyHealthBar.graphics.drawRect(0, 0, 300, 50);
			enemyHealthBar.graphics.endFill();
			enemyHealthBar.x = 680;
			enemyHealthBar.y = 550;
			this.addChild(enemyHealthBar);
			enemyTooltip = new TextField();
			enemyTooltip.defaultTextFormat = new TextFormat('Impact', 30, 0x000000);
			enemyTooltip.text = "CANINE SWORDSMAN";
			enemyTooltip.x = 700;
			enemyTooltip.y = 610;
			enemyTooltip.width = 300;
			this.addChild(enemyTooltip);
			
			playerAlive = true; //Yes, the player is in fact alive
			enemyAlive = true; //Yes, the enemy is in fact alive
			
			//BUTTONS
			//Attack Button
			attackBtnBorder = new Sprite();
			attackBtnBorder.graphics.beginFill(0x000000);
			attackBtnBorder.graphics.drawRect(45, 675, 135, 60);
			attackBtnBorder.graphics.endFill();
			this.addChild(attackBtnBorder);
			attackBtn = new Sprite();
			attackBtn.graphics.beginFill(0xFF0000);
			attackBtn.graphics.drawRect(50, 680, 125, 50);
			attackBtn.graphics.endFill();
			this.addChild(attackBtn);
			attackText = new TextField();
			attackText.defaultTextFormat = new TextFormat('Impact', 30, 0x000000);
			attackText.text = "ATTACK";
			attackText.x = 65;
			attackText.y = 685;
			attackText.selectable = false;
			this.addChild(attackText);
			//Block Button
			blockBtnBorder = new Sprite();
			blockBtnBorder.graphics.beginFill(0x000000);
			blockBtnBorder.graphics.drawRect(185, 675, 135, 60);
			blockBtnBorder.graphics.endFill();
			this.addChild(blockBtnBorder);
			blockBtn = new Sprite();
			blockBtn.graphics.beginFill(0xFF9900);
			blockBtn.graphics.drawRect(190, 680, 125, 50);
			blockBtn.graphics.endFill();
			this.addChild(blockBtn);
			blockText = new TextField();
			blockText.defaultTextFormat = new TextFormat('Impact', 30, 0x000000);
			blockText.text = "BLOCK";
			blockText.x = 210;
			blockText.y = 685;
			blockText.selectable = false;
			this.addChild(blockText);
			//Charge Button
			chargeBtnBorder = new Sprite();
			chargeBtnBorder.graphics.beginFill(0x000000);
			chargeBtnBorder.graphics.drawRect(325, 675, 135, 60);
			chargeBtnBorder.graphics.endFill();
			this.addChild(chargeBtnBorder);
			chargeBtn = new Sprite();
			chargeBtn.graphics.beginFill(0xCC66FF);
			chargeBtn.graphics.drawRect(330, 680, 125, 50);
			chargeBtn.graphics.endFill();
			this.addChild(chargeBtn);
			chargeText = new TextField();
			chargeText.defaultTextFormat = new TextFormat('Impact', 30, 0x000000);
			chargeText.text = "CHARGE";
			chargeText.x = 342;
			chargeText.y = 685;
			chargeText.selectable = false;
			this.addChild(chargeText);
			
			//this.addEventListener(Event.ENTER_FRAME, Fight, false, 0, true);
			Fight();
		} //end Init((e:Event = null) function
		
		public function Fight(e:Event = null) {
			attackText.addEventListener(MouseEvent.CLICK, PlayerAttack, false, 0, true);
			blockText.addEventListener(MouseEvent.CLICK, PlayerBlock, false, 0, true);
			chargeText.addEventListener(MouseEvent.CLICK, PlayerCharge, false, 0, true);
			/*if ((!enemyBlock) && (!enemyCharge)) {
				if (stage.getChildByName("enemy_Attack") != null) {
					stage.removeChild(enemy_Attack);
					stage.addChild(enemyDog);
				}
			}
			if ((!playerBlock) && (!playerCharge)) {
				if (stage.getChildByName("player_Attack") != null) {
					stage.removeChild(player_Attack);
					stage.addChild(playerCat);
				}
			}*/
		}//end function Fight()
		
		public function PlayerAttack(e:MouseEvent) {
			attackText.removeEventListener(MouseEvent.CLICK, PlayerAttack);
			blockText.removeEventListener(MouseEvent.CLICK, PlayerBlock);
			chargeText.removeEventListener(MouseEvent.CLICK, PlayerCharge);
			playerAttack = true;
			trace("PLAYER ATTACK");
			//player_Attack.addEventListener(Event.ENTER_FRAME, movePlayer, false, 0, true);
			if (playerCharge) {
				if (enemyBlock) { 
					enemyCurrentHealth -= 20;  
					enemyOldScale = enemyNewScale;
					enemyNewScale -= 0.2;
				} else { 
					enemyCurrentHealth -= 50;
					enemyOldScale = enemyNewScale;
					enemyNewScale -= 0.5;
				}
				playerCharge = false;
				playerCat.x = player_Charge.x;
				playerCat.y = player_Charge.y;
				stage.removeChild(player_Charge);
				stage.addChild(playerCat);
			} else {
				player_Attack.x = playerCat.x;
				player_Attack.y = playerCat.y;
				stage.removeChild(playerCat);
				stage.addChild(player_Attack);
				if (enemyBlock) { 
					enemyCurrentHealth -= 10;  
					enemyOldScale = enemyNewScale;
					enemyNewScale -= 0.1;
				} else { 
					enemyCurrentHealth -= 20;
					enemyOldScale = enemyNewScale;
					enemyNewScale -= 0.2;
				}
				playerCat.x = player_Attack.x;
				playerCat.y = player_Attack.y;
				stage.removeChild(player_Attack);
				stage.addChild(playerCat);
			}
			var tween:Tween = new Tween(enemyHealthBar, "scaleX", None.easeOut, enemyOldScale, enemyNewScale, 0.3, true);
			if (enemyCurrentHealth <= 0) { this.dispatchEvent(new Event("VICTORY")); }
			AI();
		}//end function playerAttack(e:Event)
		
		public function PlayerBlock(e:MouseEvent) {
			attackBtn.removeEventListener(MouseEvent.CLICK, PlayerAttack);
			blockBtn.removeEventListener(MouseEvent.CLICK, PlayerBlock);
			chargeBtn.removeEventListener(MouseEvent.CLICK, PlayerCharge);
			playerBlock = true;
			player_Block.x = playerCat.x;
			player_Block.y = playerCat.y;
			stage.removeChild(playerCat);
			stage.addChild(player_Block);
			AI();
		}//end function playerBlock(e:Event)
		
		public function PlayerCharge(e:MouseEvent) {
			attackBtn.removeEventListener(MouseEvent.CLICK, PlayerAttack);
			blockBtn.removeEventListener(MouseEvent.CLICK, PlayerBlock);
			chargeBtn.removeEventListener(MouseEvent.CLICK, PlayerCharge);
			playerCharge = true;
			player_Charge.x = playerCat.x;
			player_Charge.y = playerCat.y;
			stage.removeChild(playerCat);
			stage.addChild(player_Charge);
			AI();
		}//end function playerCharge(e:Event)
		
		public function AI() {
			if (enemyAlive) {
				if (!enemyCharge) { //if the enemy didn't charge last turn
					if ((enemyCurrentHealth <= 25) && (playerCharge)) {
						playerCat.x = player_Charge.x;
						playerCat.y = player_Charge.y;
						stage.removeChild(player_Charge);
						stage.addChild(playerCat);
						enemyBlock = true;
					} else if (playerCurrentHealth <= 50) {
						enemyCharge = true;
					} else if (playerCurrentHealth > 50) {
						if (playerBlock) { 
							playerBlock = false;
							playerCat.x = player_Block.x;
							playerCat.y = player_Block.y;
							stage.removeChild(player_Block);
							stage.addChild(playerCat);
							playerCurrentHealth -= 10; 
							playerOldScale = playerNewScale;
							playerNewScale -= 0.1;
						} else {
							playerCurrentHealth -= 20; 
							playerOldScale = playerNewScale;
							playerNewScale -= 0.2;
						}
					}
				} else {
					enemy_Attack.x = enemyDog.x;
					enemy_Attack.y = enemyDog.y;
					stage.removeChild(enemyDog);
					stage.addChild(enemy_Attack);
					enemyCharge = false;
					if (playerBlock) {
						playerCat.x = player_Block.x;
						playerCat.y = player_Block.y;
						stage.removeChild(player_Block);
						stage.addChild(playerCat);
						playerCurrentHealth -= 30;
						playerOldScale = playerNewScale;
						playerNewScale -= 0.2;
						playerBlock = false; 
					} else {
						playerCurrentHealth -= 40;
						playerOldScale = playerNewScale;
						playerNewScale -= 0.4;
					}
					enemyDog.x = enemy_Attack.x;
					enemyDog.y = enemy_Attack.y;
					stage.removeChild(enemy_Attack);
					stage.addChild(enemyDog);
				}//end else
				var tween:Tween = new Tween(playerHealthBar, "scaleX", None.easeOut, playerOldScale, playerNewScale, 0.3, true);
				playerHealthText.text = (playerCurrentHealth + "/" + playerHealth);
				if (playerCurrentHealth <= 0) {
					enemyAlive = false;
					this.dispatchEvent(new Event("DEFEAT"));
				} else { Fight(); }
			}//end if(enemyAlive)
		}//end function AI()
	}//end class Battle
}//end package

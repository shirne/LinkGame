package  {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	public class SkinConfig {
		
		public var Link:LinkGame;
		public var skinList:XMLList;
		
		public static var btnColor:uint = 0x009cff;
		public static var btnTextColor:uint=0xffffff;

		public static var layerColor:uint = 0xffffff;
		public static var layerAlpha:Number = .6;
		public static var layerTextColor:uint=0x333333;
		
		public var skinBox:Sprite;
		public var skinButtons:Vector.<LButton>;
		public var closeBtn:LButton;
		public var inStage:Boolean=false;
	
		public function SkinConfig(link:LinkGame, skins:XMLList) {
			this.Link = link;
			skinList = skins;
			initSkin();
		}
		
		public function initSkin(deep:Boolean=false):void{
			if(Link.config.skin.length()<1)return;
			var skin:XML = Link.config.skin[0];
			if(skin.button.length()){
				btnColor = uint(skin.button.color);
				btnTextColor = uint(skin.button.text);
			}
			if(skin.layer.length()){
				layerColor = uint(skin.layer.color);
				layerAlpha = Number(skin.layer.alpha);
				layerTextColor = uint(skin.layer.text);
			}
		}
		
		public function showSelect():void{
			var i:int;
			if(!skinBox){
				skinBox = new Sprite();
				skinButtons = new Vector.<LButton>();
				for(i = 0; i< skinList.length(); i++){
					skinButtons.push(skinButton(skinList[i], i));
					skinButtons[i].data.skin = skinList;
					skinBox.addChild(skinButtons[i]);
				}
				closeBtn = new LButton('X',cancelSkin);
				closeBtn.setPadding(3,0);
				closeBtn.textFormat = new TextFormat('Arial',10,0xffffff);
			}
			closeBtn.setColor(btnColor, btnTextColor);
			skinBox.graphics.clear();
			for(i=0;i<skinButtons.length;i++){
				skinButtons[i].setColor(btnColor, btnTextColor);
				skinButtons[i].addEventListener(MouseEvent.CLICK,changeSkin);
				skinButtons[i].x = (i%2==1)?220:20;
				skinButtons[i].y = Math.floor(i * .5) * 30 + 20;
			}
			skinBox.graphics.beginFill(0xffffff,.6);
			skinBox.graphics.drawRoundRect(0,0,skinBox.width+40,skinBox.height+40,5);
			skinBox.graphics.endFill();
			skinBox.addChild(closeBtn);
			closeBtn.x = skinBox.width - 25;
			closeBtn.y = 5;
			if(Link.state==1)Link.pause();
			Link.parent.addChild(skinBox);
			positionSkinBox();
			Link.stage.addEventListener(Event.RESIZE,positionSkinBox);
		}
		
		public function positionSkinBox(e:Event=null):void{
			skinBox.x = (Link.stage.stageWidth - skinBox.width)*.5;
			skinBox.y = (Link.stage.stageHeight - skinBox.height)*.5;
		}
		
		public function skinButton(sk:XML, i:int):LButton{
			var btn:LButton = new LButton(sk.@title);
			btn.data.file = String(sk);
			return btn;
		}
		
		public function changeSkin(e:MouseEvent):void{
			var btn:LButton = e.target as LButton;
			Link.reset();
			hideSkinBox();
			Link.box.visible = true;
			Link.startBtn.text=Lang.start;
			Link.loadSkin(btn.data.file);
		}
		
		public function cancelSkin(e:MouseEvent):void{
			hideSkinBox();
			if(Link.state==2)Link.start();
		}
		
		public function hideSkinBox(){
			skinBox.removeChild(closeBtn);
			for(var i:int=0;i<skinButtons.length;i++){
				if(skinButtons[i].hasEventListener(MouseEvent.CLICK)){
					skinButtons[i].removeEventListener(MouseEvent.CLICK,changeSkin);
				}
			}
			Link.parent.removeChild(skinBox);
		}
		
		public function change():void{
			
		}

	}
	
}

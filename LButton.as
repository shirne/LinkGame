package  {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.geom.Matrix;
	import flash.text.TextFormat;
	
	public class LButton extends Sprite {
		
		public var data:Object = {};
		
		private var textField:TextField;
		
		private var bgColor:uint = 0x009cff;
		
		private var forceColor:uint = 0xffffff;
		
		private var _ico:DisplayObject;
		
		private var paddingH:Number = 2;
		private var paddingV:Number = 10;
		
		private var isActive:Boolean = false;
		
		public function LButton(txt:String = "Button",clickHandle:Function = null) {
			this.buttonMode = true;
			this.mouseEnabled = true;
			this.mouseChildren = false;
			
			textField = new TextField();
			textField.defaultTextFormat = new TextFormat("微软雅黑",12,forceColor);
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.text = txt;
			textField.x = paddingV;
			textField.y = paddingH;
			addChild(textField);
			drawNormal();
			
			if(clickHandle !== null){
				this.addEventListener(MouseEvent.CLICK,clickHandle);
			}
			
			this.addEventListener(MouseEvent.MOUSE_OVER,drawHover);
			this.addEventListener(MouseEvent.MOUSE_OUT,drawNormal);
			
			this.addEventListener(MouseEvent.MOUSE_DOWN,drawActive);
			this.addEventListener(MouseEvent.MOUSE_UP,drawHover);
		}
		
		public function setColor(b:uint, f:uint):void{
			this.bgColor = b;
			this.forceColor = f;
			var tf:TextFormat = textField.defaultTextFormat;
			tf.color = this.forceColor;
			textField.defaultTextFormat = tf;
			textField.text = textField.text;
			drawNormal();
		}
		
		public function set text(txt:String):void{
			textField.text = txt;
			drawNormal();
		}
		
		public function set active(a:Boolean):void{
			this.isActive = a;
			if(this.isActive){
				this.drawActive();
			}else{
				this.drawNormal();
			}
		}
		public function get textFormat():TextFormat{
			return textField.defaultTextFormat;
		}
		public function set textFormat(tf:TextFormat):void{
			textField.defaultTextFormat = tf;
			textField.text = textField.text;
			drawNormal();
		}
		
		public function setPadding(v:Number=10,h:Number=2):void{
			paddingV = v;
			paddingH = h;
			textField.x = paddingV;
			textField.y = paddingH;
			drawNormal();
		}
		
		public function get active():Boolean{
			return this.isActive;
		}
		
		
		private function drawNormal(e:Event=null):void{
			draw(Helper.colorTrans(bgColor, 1.1), Helper.colorTrans(bgColor, .9), Helper.colorTrans(bgColor, .7));
		}
		
		private function drawActive(e:Event=null):void{
			if(e){
				isActive = true;
			}
			draw(Helper.colorTrans(bgColor, .9), Helper.colorTrans(bgColor, 1.1), Helper.colorTrans(bgColor, .7));
		}
		
		private function drawHover(e:Event=null):void{
			if(e && e.type == MouseEvent.MOUSE_UP){
				isActive = false;
			}
			draw(Helper.colorTrans(bgColor, 1.2), bgColor, Helper.colorTrans(bgColor, .7));
		}
		
		private function draw(startColor:uint, endColor:uint, lineColor:uint){
			var mtx:Matrix = new Matrix();
			mtx.createGradientBox(textField.width + paddingV * 2,textField.height + paddingH * 2,90);
			this.graphics.clear();
			this.graphics.lineStyle(1,lineColor,1,true);
			this.graphics.beginGradientFill(GradientType.LINEAR,[startColor, endColor],[1,1],[0,255],mtx);
			this.graphics.drawRoundRect(0,0, textField.width + paddingV * 2,textField.height + paddingH * 2, 5);
			this.graphics.endFill();
		}

	}
	
}

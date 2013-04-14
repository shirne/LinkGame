
/**************\
	计时系统
\**************/
package {
	import flash.utils.Timer;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.geom.Matrix;
	import flash.display.GradientType;

	public class Timing extends Sprite {
		
		public var timer:Timer = null;
		
		public var stoptime:Number=0;
		public var aTime:Number=0;
		public var sTime:Number=0;
		public var nTime:Number=0;
		
		public var ATime:TextField=null;
		public var NTime:TextField=null;
		public var TimeLine:Shape=null;
		
		public var Link:LinkGame=null;
		
		
		public var astrict:Number=0;
		
		public function Timing(link) {
			Link = link;
			
			ATime = new TextField();
			ATime.defaultTextFormat=new TextFormat("LcdD",14,0xffffff);
			ATime.text = '0';
			ATime.x = 450;
			ATime.y = Link.infoLine + 2;
			addChild(ATime);
			var ATimeLabel:TextField=new TextField();
			ATimeLabel.defaultTextFormat=new TextFormat("微软雅黑",14,0xffffff);
			ATimeLabel.autoSize = TextFieldAutoSize.LEFT;
			ATimeLabel.text = Lang.timeall;
			ATimeLabel.x = 400;
			ATimeLabel.y = Link.infoLine - 2;
			addChild(ATimeLabel);
			
			NTime = new TextField();
			NTime.defaultTextFormat=new TextFormat("LcdD",14,0xffffff);
			NTime.text = '0';
			NTime.x = 516;
			NTime.y = Link.infoLine + 2;
			addChild(NTime);
			var NTimeLabel:TextField=new TextField();
			NTimeLabel.defaultTextFormat=new TextFormat("微软雅黑",14,0xffffff);
			NTimeLabel.autoSize = TextFieldAutoSize.LEFT;
			NTimeLabel.text = Lang.time;
			NTimeLabel.x = 480;
			NTimeLabel.y = Link.infoLine - 2;
			addChild(NTimeLabel);
			
			TimeLine = new Shape();
			TimeLine.filters = [new GlowFilter(0xffffff,1,4,4)];
			TimeLine.x=0;
			TimeLine.y=Link.infoLine + 30;
			addChild(TimeLine);
			
			timer = new Timer(100);
			timer.addEventListener(TimerEvent.TIMER,timing);
		}
		
		public function get time():Number{
			var ts:Number=new Date().getTime() * .001 - this.nTime-this.sTime;
			return ts+this.aTime;
		}
		
		public function start(newLevel:int=1) {
			var d:int=new Date().getTime() * .001;
			if (stoptime) {
				sTime += Math.round(d - stoptime);
				stoptime = 0;
			} else {
				nTime = d ;
			}
			timer.start();
		}
		//暂停或停止
		public function stop( b:Boolean=false) {
			timer.reset();
			if (b) {
				var usetime=Math.round(new Date().getTime() * .001-this.nTime)-this.sTime;
				Link.user.score +=  this.astrict - usetime;//剩余时间增加为积分
				Link.user.show();
				this.aTime +=  usetime;
				this.sTime = 0;
				this.nTime = 0;
			} else {
				this.stoptime=new Date().getTime() * .001;
			}
		}
		//增加时间
		public function add( t:int=0) {
			this.astrict +=  t;
		}
		//减少时间
		public function reduce( t:int=0) {
			this.astrict -=  t;
		}
		
		public function timing(e:TimerEvent=null) {
			var ts:Number=new Date().getTime() * .001 - this.nTime-this.sTime,
			as2:Number=ts+this.aTime;
			if (ts > this.astrict) {
				Link.sound.play(SoundManager.Lose);
				Link.pause();
				Link.alert(Lang.fail(Link.user.score,as2),Link.reset);
				this.reset();
				return;
			}
			ATime.text = Math.floor(as2 / 60)+':' + Math.ceil(as2 % 60);
			NTime.text = Math.floor(ts / 60)+':' + Math.ceil(ts % 60);
			progress(ts / this.astrict);
		}
		
		public function progress(p:Number):void
		{
			var color:uint = SkinConfig.btnColor;
			TimeLine.graphics.clear();
			
			if(p > .01){
				var mtx:Matrix=new Matrix();
				mtx.createGradientBox(p * Link.mainWidth,5,90);
				TimeLine.graphics.beginGradientFill(GradientType.LINEAR,
												[Helper.colorTrans(color,1.1),Helper.colorTrans(color,.9)],
												[1,1],[0,255],mtx);
				TimeLine.graphics.drawRect(0,0,p * Link.mainWidth,5);
				TimeLine.graphics.endFill();
			}
			TimeLine.graphics.lineStyle(1,Helper.colorTrans(color,.7));
			TimeLine.graphics.drawRect(0,0,Link.mainWidth,5);
		}
		
		public function reset() {
			this.aTime = 0;//总计时,秒
			this.nTime = 0;//当前关开始时间
			this.sTime = 0;//当前关暂停的时间,秒
			this.astrict = 0;//当前关限制时间,秒
			this.stoptime = 0;//暂停时间
			timer.reset();
			ATime.text = "0";
			NTime.text = "0";
			progress(0);
		}

	}

}
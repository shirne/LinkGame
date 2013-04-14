package  {
	
	public class Lang extends Object{
		public static var selectLevel:String="选关";
		public static var help:String="帮助";
		public static var demo:String="演示";
		public static var score:String = "分数:";
		public static var time:String = "时间:";
		public static var timeall:String = "总时间:";
		
		public static var about:String=" © 2013 <a href=\"http://www.shirne.com\">临风小筑</a>";
		
		
		public static var config:String="配置";
		public static var skinConfig:String="皮肤配置";
		public static var skin:String="皮肤";
		public static var resource:String="资源";
		public static function loading(type:String):String{
			return "正在加载"+ type +"...";
		}
		public static function loadError(type:String, url:String):String{
			return type + "文件 "+ url +" 加载错误";
		}
		/*public static var loadingConfig:String="正在加载配置...";
		public static function configLoadError( f:String):String{
			return "配置文件 "+ f +" 加载错误";
		}
		public static var loadingResource:String="正在加载资源...";
		public static function resourceLoadError( f:String):String{
			return "资源文件 "+ f +" 加载错误";
		}*/
		
		public static var start:String="开始";
		public static var goon:String="继续";
		public static var pause:String="暂停";
		public static var reset:String="重置";
		public static function tip(num:int):String{
			return "提示("+ num +")";
		}
		public static function upset(num:int):String{
			return "打乱("+ num +")";
		}
		
		public static var clickStart:String="请点击开始按钮";
		public static function success(score:int,time:int):String{
			return "您已经过了所有关卡\n真是无敌呀!\n您的得分:"+score+" 分\n所用时间:"+timetoStr(time);
		}
		public static function fail(score:int,time:int):String{
			return "哎呀,\n很遗憾没时间了!\n您当前得分:"+score+"\n所用时间:"+timetoStr(time);
		}
		public static function nextLevel(title:String):String{
			return "恭喜过关\n下一关:"+ title;
		}
		
		public static function timetoStr(time:Number):String{
			var timeStr:String;
			if(time >= 60){
				timeStr = Math.floor(time / 60) + '分';
			}
			if(time % 60){
				timeStr = timeStr + (time % 60) + '秒';
			}else{
				timeStr = timeStr + '钟';
			}
			return timeStr;
		}
		public static var notStart:String="您还没有开始?";
		
		public static function noActionOver(score:int,time:int):String{
			return "无子可消\n游戏结束!\n您当前得分:"+score+"\n所用时间:"+timetoStr(time);
		}
		public static var noActionReset:String="无子可消\n重新排序";

	}
	
}

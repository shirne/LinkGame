package  {
	
	public class MoveType extends Object {
		
		//普通
		public static var NORMAL:int=0;
		//上
		public static var UP:int=1;
		//下
		public static var DOWN:int=2;
		//左
		public static var LEFT:int=3;
		//右
		public static var RIGHT:int=4;
		
		//中心,这个实现比较复杂,暂时只分四个区
		public static var CENTER:int=5;
		
		//四散,同上
		public static var SCATTER:int=6;
		
		//上下分离
		public static var UP_DOWN:int=7;
		//左右分离
		public static var LEFT_RIGHT:int=8;
		//左上右下
		public static var LEFT_UP_RIGHT_DOWN:int=9;
		//上左下右
		public static var TOP_LEFT_BOTTOM_RIGHT:int=10;
		//随机
		public static var RANDOM:int=11;


	}
	
}

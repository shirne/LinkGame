/**************\
	玩家系统
\**************/
package {
	import flash.text.TextField;

	public class User extends Object {
		
		public var score:int = 0;//积分
		public var tiptime:int = 0;//提示次数
		public var sorttime:int = 0;//重排次数
		
		
		private var Link:LinkGame=null;
		public function User(link:LinkGame) {
			Link = link;
		}

		public function reset() {
			this.score = 0;
			this.tiptime = 0;
			this.sorttime = 0;
			Link.userScore.text = String(score);
			Link.tipBtn.text=Lang.tip(tiptime);
			Link.sortBtn.text=Lang.upset(sorttime);
		}
		public function show( a:Boolean=false) {
			if (a) {
				Link.tipBtn.text=Lang.tip(tiptime);
				Link.sortBtn.text = Lang.upset(sorttime);
			} else {
				Link.userScore.text = String(score);
			}
		}


	}

}
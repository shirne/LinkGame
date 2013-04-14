package  {
	import flash.media.Sound;
	import flash.system.ApplicationDomain;
	import flash.media.SoundChannel;
	
	public class SoundManager {
		
		public static var NotMatch:Sound;
		public static var Match:Sound;
		
		public static var Lose:Sound;
		
		public static var Tip:Sound;
		
		public static var Click:Sound;
		
		public static var Clear:Sound;
		
		private var soundChannel:SoundChannel;
		
		public function SoundManager(domain:ApplicationDomain) {
			NotMatch = new (domain.getDefinition("SoundNotMatch"))();
			Match = new (domain.getDefinition("SoundMatch"))();
			Lose = new (domain.getDefinition("SoundLose"))();
			Tip = new (domain.getDefinition("SoundTip"))();
			Click = new (domain.getDefinition("SoundClick"))();
			Clear = new (domain.getDefinition("SoundClear"))();
		}
		
		public function play(sound:Sound):void{
			if(soundChannel){
				soundChannel.stop();
			}
			soundChannel = sound.play(100);
		}

	}
	
}

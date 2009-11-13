package com.tomgibara.test.override;

import android.app.Activity;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;

public class OverrideTest {

}

class A implements B {

	//INCOMPATIBLE WITH 1.5
	@Override
	public void b() {
	}

}

interface B {

	void b();

}

class C extends A {

	@Override
	public void b() {
	}
	
}

class E implements B {
	
	public void b() {
	}
}

class F implements OnClickListener {
	
	//INCOMPATIBLE WITH 1.5
	@Override
	public void onClick(View v) {
	}
}

class G implements OnTouchListener {
	
	public boolean onTouch(View v, MotionEvent event) {
		return false;
	}
}

class H extends Activity {
	
	@Override
	protected void onStart() {
	}
}

interface I {
	
	void i();
	
	static class J implements I {
		
		//INCOMPATIBLE WITH 1.5
		@Override
		public void i() {
		}
		
	}
	
}

class K {
	
	void k() {
	}
	
	private class L extends K {
		
		@Override
		void k() {
		}
		
	}
}

class M implements B {
	
	//INCOMPATIBLE WITH 1.5
	@Override
	@Deprecated
	public void b() {
	}
	
}

abstract class N implements B {

	//INCOMPATIBLE WITH 1.5
	@Override
	public abstract void b();

}

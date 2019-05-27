using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.ActivityMonitor as Act;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;

class GOTWatchFaceView extends Ui.WatchFace {

    var customFont = null;
	var monImage = null;
	var bgColor = 0x000000;
	var timeColor = 0x3366ff;
	var winterColor = 0x6699ff;
	var secColor = 0xffffff;
	var batteryColor = 0xffffff;

    // Load your resources here
    function onLayout(dc) {
    	
    	customFont = Ui.loadResource(Rez.Fonts.customFont);
        monImage = Ui.loadResource(Rez.Drawables.got); 
    }
    
    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        
        var clockTime = Sys.getClockTime();   
        var sec  = clockTime.sec;      
        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        var stats = Sys.getSystemStats();
        var infos = Act.getInfo();
        
        // Set Background Color        
        dc.setColor(bgColor, bgColor); 
        dc.clear();
        
        // Display Time
        dc.setColor(timeColor, bgColor);        
        dc.drawText(dc.getWidth()/2, 24 , customFont, timeString, Gfx.TEXT_JUSTIFY_CENTER);
        
        // Set Background image
        dc.drawBitmap(dc.getWidth()/2 - 50, 120, monImage);
        
        // Battery info
        dc.setColor(batteryColor, bgColor);
        dc.drawText(dc.getWidth()/2 - 85, 105 , Graphics.FONT_XTINY, stats.battery.format("%02d")+"%", Gfx.TEXT_JUSTIFY_CENTER);
        
        // Update goals
        var goal = infos.stepGoal;
        var steps = infos.steps;
        var tmp = 360;   
            
        if(steps < goal) {
        	tmp = ( steps.toFloat() / goal.toFloat()) * 360;
        }
        
        if(tmp.toNumber() != 0) {
        	dc.setPenWidth(8);
        	dc.setColor(winterColor, Gfx.COLOR_TRANSPARENT);        	
    		dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, dc.getWidth()/2 - 1, Gfx.ARC_COUNTER_CLOCKWISE, 90, tmp.toNumber() + 90);
    	}
      
        updateSecWidget(dc);
    	updateHeartRate(dc); 		    	
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
   	}

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }
    
    // Update a portion of the screen
    function onPartialUpdate(dc) {
    
    	updateSecWidget(dc);    	
    	updateHeartRate(dc);
    }
    
    // Handle a partial update exceeding the power budget
    function onPowerBudgetExceeded() {
    }
    
    function updateSecWidget(dc) {
    
    	var clockTime = Sys.getClockTime(); 
        var sec  = clockTime.sec;
    	
    	dc.setClip(dc.getWidth()/2 + 65, 105, 40, 28);
    	dc.setColor(secColor, bgColor);    	
	dc.drawText(dc.getWidth()/2 + 85, 105 , Graphics.FONT_XTINY, sec.format("%02d") , Gfx.TEXT_JUSTIFY_CENTER);
	dc.clearClip();	
    	
    }
    
    function updateHeartRate(dc) {
    
    	var heartColor = null;	    
	    
	var hrIter         = Act.getHeartRateHistory(1, true);
        var hr             = hrIter.next();
        var bpm            = (hr.heartRate != Act.INVALID_HR_SAMPLE && hr.heartRate > 0) ? hr.heartRate : 0;      
				               
	if(bpm<110) { 
		// 0 to 110
		heartColor = 0xffffff;
	} else if(bpm<150) {
		// 110 to 150
	    heartColor = 0x00ff00;
	} else if(bpm<170) {
		//150 to 170
	    heartColor = 0xff8c00;
	} else {
		// over 170
		heartColor = 0xff0000;
	}	 
						
				        
	dc.setClip(dc.getWidth()/2 - 20, 105, 40, 28);
	dc.setColor(heartColor, bgColor);    	
	dc.drawText(dc.getWidth()/2, 105 , Graphics.FONT_XTINY, bpm , Gfx.TEXT_JUSTIFY_CENTER);
	dc.clearClip();	
    }

}

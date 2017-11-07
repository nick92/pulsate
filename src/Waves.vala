using Gtk;
using Clutter;
using GtkClutter;
using Gst;

namespace Waves {
	public class Main : Gtk.Application {
		Clutter.Actor actors;
		Clutter.Stage stage;
		GtkClutter.Embed clutter;
		Gtk.Window window;
		Pulse pulse;
		FFTStreamer fft;
		Gst.Pipeline pip;
		int spect_bands = 30;
		int AUDIOFREQ = 32000;

		public Main () {
			window = new Gtk.Window();
			window.set_size_request(640, 480);
			window.set_title("Pulsate");
			window.destroy.connect( () => Gtk.main_quit());
			actors = new Clutter.Actor();
			fft = new FFTStreamer();
			
			//pulse = new Pulse ();
			//pulse.start();
			clutter = new GtkClutter.Embed();
	        stage = clutter.get_stage () as Clutter.Stage;
	        stage.background_color = { 255, 255, 255, 255 };
			//box = clutter_window.get_stage();

	        for(int i = 0; i < spect_bands; i++){
				var actor_i = new Clutter.Actor ();
				actor_i.background_color = { 0, 255, 0, 128 };
				actor_i.set_size(20, 1);
				actor_i.set_position(20*i, 10);
				//actor_i.set_rotation(RotateAxis.X_AXIS, )
				actors.add_child(actor_i);
			}

			stage.add_child(actors);
			window.add(clutter);

			//this.thread_start();
			this.window.show_all();
			
			pip = fft.play("stream");

			Gst.Bus bus = pip.get_bus ();
        	bus.add_watch (0, bus_callback);
		}

		private bool bus_callback (Gst.Bus bus, Gst.Message message) {
	        switch (message.type) {
	            case Gst.MessageType.ELEMENT:

					int i = 0;	                
					
	                //var mag = ValueList.get_value(magnitude, 0);
	            	GLib.Value magnitudes = message.get_structure ().copy ().get_value ("magnitude");
	            	GLib.Value phases = message.get_structure ().copy ().get_value ("phase");
                    
					for (i = 0; i < spect_bands; ++i) {
						var freq = (float) ((AUDIOFREQ / 2) * i + AUDIOFREQ / 4) / spect_bands;
						var mag = ValueList.get_value(magnitudes, i);
						var phase = ValueList.get_value(phases, i);
						
						if (mag != null && phase != null) {
							//print(mag.get_float ().to_string() +"\n");
							//print(phase.get_float ().to_string() +"\n");

							var dphase = phase.get_float() * -10; 

							expand_actor(actors.get_child_at_index(i), dphase);
						}
					}
	                //stdout.printf ("%s\n\n", magnitude.strdup_contents ());

	                //string[] mags = magnitude.dup_string ();
					//stdout.printf ("%s\n\n", mags[0]);	      */          
	                //expand_actor(actors.get_child_at_index(1), )
	            
	                break;
	            case Gst.MessageType.STATE_CHANGED:
	                stdout.printf ("hummm");
	                break;
	            case Gst.MessageType.ERROR:
	                GLib.Error err;
	                string debug;
	                message.parse_error (out err, out debug);
	                warning (err.message);
	                break;
	            case Gst.MessageType.EOS:
	                //FIXME: stream ends here, maybe start dumping in sinewaves or perlin noise to keep rendering noice.
	                break;
	            default:
	                break;
	        }

	        return true;
	    }

		public static int main(string[] args) {
	        var init = GtkClutter.init (ref args);
	        Gst.init (ref args);

	        if (init != Clutter.InitError.SUCCESS) {
		        error ("Clutter could not be intiailized");
		    }

	        var app = new Main ();

	        Gtk.main();
	        //return app.run(args);
	        return 0;
    	}

    	Clutter.PropertyTransition expand_actor (Clutter.Actor actor, double i_height) {
	        var transition = new Clutter.PropertyTransition ("height");
	        transition.animatable = actor;
	        transition.set_duration (6000);
	        transition.set_progress_mode (Clutter.AnimationMode.EASE_OUT_CIRC);
	        transition.set_from_value (actor.height);
	        transition.set_to_value (i_height);

	        if(actor.get_transition (i_height.to_string()) == null){
        		actor.add_transition (i_height.to_string(), transition);
        	}

	        return transition;
	    }
	}
} 

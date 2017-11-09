using Gtk;
using Clutter;
using GtkClutter;
using Gst;
using Cairo;

namespace Waves {
	public class Main : Gtk.Application {
		Clutter.Actor actors;
		Clutter.Canvas canvas;
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
			canvas = new Clutter.Canvas();
			fft = new FFTStreamer();
			
			//pulse = new Pulse ();
			//pulse.start();
			clutter = new GtkClutter.Embed();
	        stage = clutter.get_stage () as Clutter.Stage;
	        stage.background_color = { 255, 255, 255, 255 };
			//box = clutter_window.get_stage();

	        for(int i = 0; i < spect_bands; i++){
				var actor_i = new Clutter.Actor ();
				actor_i.background_color = { 100, 255, 0, 200 };
				actor_i.set_size(15, 1);
				actor_i.set_position(20*i, 10);
				//actor_i.set_rotation(RotateAxis.X_AXIS, )
				actors.add_child(actor_i);
			}

			canvas.set_size(200, 200);

			stage.set_content(canvas);
			//stage.add_child(actors);

			//window.add(clutter);
			window.add(clutter);

			//this.thread_start();
			this.window.show_all();
			
			pip = fft.play("stream");

			Gst.Bus bus = pip.get_bus ();
        	bus.add_watch (0, bus_callback);

			canvas.draw.connect(drawing_on_canvas);	
			canvas.invalidate();
		}

		private bool drawing_on_canvas(Cairo.Context ctx, int width, int height) {
			int SIZE = 20;

			//ctx.set_source_rgb (0, 0, 0);

		    // Red box:
		    for(int i = 0; i < spect_bands; i++){
				ctx.set_source_rgba (1, 0, 0, 1);
				ctx.rectangle (25, 25, 75, 75);
				ctx.fill ();
			}
		    
			return true;
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

							var dphase = mag.get_float() * -1; 

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
	        transition.set_duration (1);
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

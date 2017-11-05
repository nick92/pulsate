using PulseAudio;


public class Pulse : GLib.Object {
    private PulseAudio.GLibMainLoop loop;
    private PulseAudio.Context context;
    private Context.Flags cflags;
    private PulseAudio.SampleSpec spec;
    private PulseAudio.Stream.BufferAttr attr;
    private PulseAudio.Simple simple;
    private double twopi_over_sr;
    private string s_default_sink;

    public Pulse () {
        GLib.Object();
    }

    construct {
        this.spec = PulseAudio.SampleSpec() {
                format = PulseAudio.SampleFormat.S16LE,
                                         channels = 2,
                                         rate =  44100
        };
        twopi_over_sr = (2.0 * Math.PI) / (double)spec.rate;
    }

    public void start () {
        this.loop = new PulseAudio.GLibMainLoop(); // there are other loops that can be used if you are not using glib/gtk main
        this.context = new PulseAudio.Context(loop.get_api(), null);
        this.cflags = Context.Flags.NOFAIL;
        this.context.set_state_callback(this.cstate_cb);

        // Connect the context
        if (this.context.connect( null, this.cflags, null) < 0) {
                print( "pa_context_connect() failed: %s\n", 
                           PulseAudio.strerror(context.errno()));
        }
    }

    public void stream_over_cb(Stream stream) {
        print("AudioDevice: stream overflow...\n");
    }
    public void stream_under_cb(Stream stream) {
        print("AudioDevice: stream underflow...\n");
    }


    public int16[] read() {
        print("reading");
        size_t nbytes = 1024;
        uint len = (uint)(nbytes / sizeof(int16));
        int16[] data = new int16[ len ];    
        this.attr = PulseAudio.Stream.BufferAttr();
        attr.maxlength = 2048;
        attr.fragsize = 1024;

        int error, i;
        int n = 0;

        //while(true){
            this.simple = new PulseAudio.Simple(null, "Waves listener", Stream.Direction.RECORD, s_default_sink, "audio for waves", spec, null, attr, out error);

            simple.read((void *)data, sizeof(size_t), out error);
            for(i=0; i < len; i+= spec.channels) {
                if(data[i] != 0){
                    //print(data[i].to_string());
                    //print(data[i+1].to_string());
                }

                n++;
                if(n == nbytes * 2)
                    n = 0;
            }
        //}
        return data;   
    }

    public void server_info_cb(Context c, ServerInfo? i){
        //print(i.default_sink_name+".monitor");
        s_default_sink = i.default_sink_name+".monitor";
    }

    // state callback, don't connect_playback until we are ready here.
    public void cstate_cb(Context context){
        Context.State state = context.get_state();
        if (state == Context.State.UNCONNECTED) { print("state UNCONNECTED\n"); }
        if (state == Context.State.CONNECTING) { print("state CONNECTING\n"); } 
        if (state == Context.State.AUTHORIZING) { print("state AUTHORIZING,\n"); }
        if (state == Context.State.SETTING_NAME) { print("state SETTING_NAME\n"); }
        if (state == Context.State.READY) { print("state READY\n"); }
        if (state == Context.State.FAILED) { print("state FAILED,\n"); }
        if (state == Context.State.TERMINATED) { print("state TERMINATED\n"); }

        if (state == Context.State.READY) {
            this.attr = PulseAudio.Stream.BufferAttr();
            this.context.get_server_info(this.server_info_cb);
        }
    }
}
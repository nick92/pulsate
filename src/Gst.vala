using Gst;

public class FFTStreamer {
    public signal void fft_update ();    

    private Gst.Pipeline pipeline;
    private Gst.Element source;
    private Gst.Element spectrum;
    private Gst.Element sink;
    private MainLoop loop = new MainLoop ();

    public Gst.Pipeline play (string stream) {
        pipeline = new Gst.Pipeline ("pipeline");

        source = Gst.ElementFactory.make ("pulsesrc", "source");
        source.set_property ("client-name", "Pulseate");

        spectrum = Gst.ElementFactory.make ("spectrum", "spectrum");
        spectrum.set_property ("multi-channel", true);
        spectrum.set_property ("interval", 100000000);
        spectrum.set_property ("bands", 20);
        spectrum.set_property ("post-messages", true);
        spectrum.set_property ("message-magnitude", true);

        sink = Gst.ElementFactory.make ("fakesink", "sink");

        pipeline.add_many (source, spectrum, sink);
        source.link (spectrum);
        spectrum.link (sink);

        pipeline.set_state (State.PLAYING);

        return pipeline;
        //loop.run ();
    }

    public void close_stream () {
        loop.quit ();
    }


    public void change_source () {
        //write me :D
    }
}
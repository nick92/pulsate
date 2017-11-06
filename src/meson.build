sources = [
    'Waves.vala',
	'Pulse.vala',
	'Gst.vala'
]

executable ('Pulsate',
            sources,
            dependencies: [mainpulseaudio, pulseaudio, glib, gtk, clutter, cluttergtk, simplepulse, gstreamer],
            vala_args:['--target-glib=2.38', '--gresources=' + meson.source_root () + '/data/Pulsate-resource.xml'],
            install: true
            )

project ('pulsate', ['vala', 'c'])

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')], language: 'vala')

glib = dependency ('glib-2.0')
gtk = dependency ('gtk+-3.0')
clutter = dependency ('clutter-1.0')
cluttergtk = dependency ('clutter-gtk-1.0')
pulseaudio = dependency ('libpulse')
mainpulseaudio = dependency ('libpulse-mainloop-glib') 
simplepulse = dependency ('libpulse-simple')
gstreamer = dependency ('gstreamer-1.0') 
subdir ('src')

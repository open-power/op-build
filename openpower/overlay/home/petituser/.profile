export ENV="/home/petituser/.shrc"

if [ "$PPID" = "1" ]; then
	exec /usr/libexec/petitboot/pb-console
fi

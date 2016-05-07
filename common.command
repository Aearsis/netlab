if [ -S bird.sock ]; then
	./birdc -s bird.sock "$*"
fi

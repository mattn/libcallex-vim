all : libcallex.so
	@echo done

libcallex.so : libcallex.cxx
	g++ -static-libgcc -static-libstdc++ -shared -o libcallex.so libcallex.cxx -lffi

all : libcallex.so
	@echo done

libcallex.so : libcallex.cxx
	g++ -static-libgcc -fPIC -static-libstdc++ -shared -o libcallex.so libcallex.cxx -lffi

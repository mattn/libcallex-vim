#include <windows.h>
#include "picojson.h"

extern "C" _declspec(dllexport)
const char* libcallex_loadlib(const char* libname) {
	HANDLE h = LoadLibrary(libname);
	static char buf[20];
	sprintf(buf, "%ld", (long) h);
	return buf;
}

extern "C" _declspec(dllexport)
const char* libcallex_call(const char* context) {
	picojson::value v;
	static std::string r;
	std::string err = picojson::parse(v, context, context + strlen(context));
	if (!err.empty() || !v.is<picojson::object>()) {
		return "";
	}
	unsigned long _r = 0;
	picojson::object obj = v.get<picojson::object>();
	HINSTANCE h = (HINSTANCE) (long) obj["handle"].get<double>();
	std::string f = obj["function"].get<std::string>();

	typedef int (__stdcall *FUNCTION)(void);
	FUNCTION _p = GetProcAddress(h, f.c_str());

	picojson::array arg = obj["arguments"].get<picojson::array>();
	unsigned long narg = 0;
	unsigned long* args = new unsigned long[arg.size()];
	for (picojson::array::iterator it = arg.begin();
			it != arg.end(); it++) {
		args[narg] = 0;
		if (it->is<std::string>()) {
			args[narg] = (unsigned long)(it->get<std::string>().c_str());
		} else
		if (it->is<double>()) {
			args[narg] = (unsigned long)(it->get<double>());
		} else
		if (it->is<bool>()) {
			args[narg] = (unsigned long)(it->get<bool>());
		}
		narg++;
	}
	for (unsigned long n = 0; n < narg; n++) {
		unsigned long Arg = args[narg-n-1];
		_asm {
			mov eax, Arg
			push eax
		}
	}
	_asm {
		call _p
		mov _r, eax
	}
	r += _r;
	delete args;
	return r.c_str();
}

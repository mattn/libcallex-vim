#include <windows.h>
#include <sstream>
#include "picojson.h"

extern "C" _declspec(dllexport)
const int libcallex_load(const char* libname) {
	return (long ) LoadLibrary(libname);
}

extern "C" _declspec(dllexport)
const char* libcallex_call(const char* context) {
	static std::string r;
	picojson::value v;
	std::string err = picojson::parse(v, context, context + strlen(context));
	if (!err.empty()) {
		return "faild to parse arguments";
	}
	if (!v.is<picojson::object>()) {
		return "unknown type of arguments";
	}
	picojson::object obj = v.get<picojson::object>();
	unsigned long* args = NULL;
	try {
		unsigned long r_ = 0;
		HINSTANCE h = (HINSTANCE) (long) obj["handle"].get<double>();
		std::string f = obj["function"].get<std::string>();

		typedef int (__stdcall *FUNCTION)(void);
		FUNCTION p_ = GetProcAddress(h, f.c_str());

		std::string rettype = obj["rettype"].get<std::string>();
		picojson::array arg = obj["arguments"].get<picojson::array>();
		unsigned long narg = 0;
		args = new unsigned long[arg.size()];
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
#if defined(_MVC_VER)
		for (unsigned long n = 0; n < narg; n++) {
			unsigned long a_ = args[narg-n-1];
			_asm {
				mov eax, a_
				push eax
			}
		}
		_asm {
			call p_
			mov r_, eax
		}
#elif defined(__GNUC__)
		for (unsigned long n = 0; n < narg; n++) {
			unsigned long a_ = args[narg-n-1];
			__asm__ (
				"mov %%eax, %0;"
				"push %%eax;"
				::"r"(a_):"%eax"
			);
		}
		__asm__ (
			"call %%eax;"
			:"=r"(r_)
			:"r"(p_)
		);
#endif
		std::stringstream ss;
		if (rettype.empty() || rettype == "number") {
			ss << double(r_);
		} else
		if (rettype == "string") {
			ss << (char*)r_;
		} else
		if (rettype == "boolean") {
			ss << int(r_); // shouldn't return string 'true/false'
		}

		obj["return"] = ss.str();
		v = obj;
		r = v.serialize();
	} catch(...) {
		// perhaps, can't catch access violation of windows for gcc
		LPVOID lpMessageBuffer;
		FormatMessage(
				FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM,
				NULL,
				GetLastError(),
				MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
				(LPTSTR) &lpMessageBuffer,
				0,
				NULL);
		obj["error"] = (char*)lpMessageBuffer;
		LocalFree(lpMessageBuffer);
		GetLastError();
		r = v.serialize();
	}
	if (args) delete[] args;
	return r.c_str();
}

extern "C" _declspec(dllexport)
const char* libcallex_free(const char* context) {
	picojson::value v;
	std::string err = picojson::parse(v, context, context + strlen(context));
	if (!err.empty() || !v.is<picojson::object>()) {
		return "";
	}
	picojson::object obj = v.get<picojson::object>();
	HINSTANCE h = (HINSTANCE) (long) obj["handle"].get<double>();
	FreeLibrary(h);
	return "";
}

#ifdef _WIN32
#include <windows.h>
#define EXPORT "C" _declspec(dllexport)
#else
#include <dlfcn.h>
#define EXPORT
#endif
#include <sstream>
#include "picojson.h"

extern "C" {

EXPORT
const int libcallex_load(const char* libname) {
#ifdef _WIN32
	return (long ) LoadLibrary(libname);
#else
	return (long ) dlopen(libname, RTLD_LAZY);
#endif
}

EXPORT
const char* libcallex_call(const char* context) {
	static std::string r;
	picojson::value v;
	std::string err = picojson::parse(v, context, context + strlen(context));
	if (!err.empty()) {
		return "failed to parse arguments";
	}
	if (!v.is<picojson::object>()) {
		return "unknown type of arguments";
	}
	picojson::object obj = v.get<picojson::object>();
	unsigned long* args = NULL;
	try {
		unsigned long r_ = 0;
		void* h = (void*) (long) obj["handle"].get<double>();
		std::string f = obj["function"].get<std::string>();

#ifdef _WIN32
		typedef int (__stdcall *FUNCTION)(void);
		FUNCTION p_ = (FUNCTION) GetProcAddress(h, f.c_str());
#else
		typedef int (*FUNCTION)(void);
		FUNCTION p_ = (FUNCTION) dlsym((void *) h, f.c_str());
#endif

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
			ss << static_cast<double>(r_);
		} else
		if (rettype == "string") {
			ss << static_cast<char*>(*(char**)&r_);
		} else
		if (rettype == "boolean") {
			ss << static_cast<int>(r_); // shouldn't return string 'true/false'
		}

		obj["return"] = ss.str();
		v = obj;
		r = v.serialize();
	} catch(...) {
		// perhaps, can't catch access violation of windows for gcc
#ifdef _WIN32
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
#else
		obj["error"] = dlerror();
#endif
		r = v.serialize();
	}
	if (args) delete[] args;
	return r.c_str();
}

EXPORT
const char* libcallex_free(const char* context) {
	picojson::value v;
	std::string err = picojson::parse(v, context, context + strlen(context));
	if (!err.empty() || !v.is<picojson::object>()) {
		return "";
	}
	picojson::object obj = v.get<picojson::object>();
	void* h = (void*) (long) obj["handle"].get<double>();
#ifdef _WIN32
	FreeLibrary(h);
#else
	dlclose(h);
#endif
	return "";
}

}

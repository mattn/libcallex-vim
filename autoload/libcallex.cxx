#ifdef _WIN32
#include <windows.h>
#define EXPORT __declspec(dllexport)
#else
#include <dlfcn.h>
#define EXPORT
#endif
#include <sstream>
#include "picojson.h"

#ifdef _WIN64
# define INTPTR_T long long
#else
# define INTPTR_T long
#endif

extern "C" {

static std::string ptr2str(void* p) {
	std::stringstream ss;
	ss << p;
	return ss.str();
}

static void* str2ptr(std::string s) {
	void *p;
	std::stringstream ss(s);
	ss >> p;
	return p;
}

EXPORT
const char* libcallex_load(const char* libname) {
	static std::string _r;
	void *p;
#ifdef _WIN32
	p = (void*)LoadLibrary(libname);
#else
	p = (void*)dlopen(libname, RTLD_LAZY);
#endif
	_r = ptr2str(p);
	return _r.c_str();
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
	INTPTR_T* args = NULL;
	try {
		INTPTR_T r_ = 0;
		void* h = str2ptr(obj["handle"].get<std::string>());
		std::string f = obj["function"].get<std::string>();

#ifdef _WIN32
		typedef int (__stdcall *FUNCTION)(void);
		FUNCTION p_ = (FUNCTION) GetProcAddress((HMODULE) h, f.c_str());
#else
		typedef int (*FUNCTION)(void);
		FUNCTION p_ = (FUNCTION) dlsym((void *) h, f.c_str());
#endif

		std::string rettype = obj["rettype"].get<std::string>();
		picojson::array arg = obj["arguments"].get<picojson::array>();
		unsigned long narg = 0;
		args = new INTPTR_T[arg.size()];
		for (picojson::array::iterator it = arg.begin();
				it != arg.end(); it++) {
			if (it->is<std::string>()) {
				args[narg] = (INTPTR_T)(it->get<std::string>().c_str());
			} else
			if (it->is<double>()) {
				args[narg] = (INTPTR_T)(it->get<double>());
			} else
			if (it->is<bool>()) {
				args[narg] = (INTPTR_T)(it->get<bool>());
			}
			narg++;
		}
#if defined(_WIN64) && defined(_MSC_VER)
		// NOTE: Vim's Number is 32bit. We can not handle 64bit pointer as Number.
		// FIXME: double is not supported
		extern intptr_t msc_x64_call(FUNCTION p, long narg, INTPTR_T* args);
		r_ = msc_x64_call(p_, narg, args);
#elif defined(_WIN32) && defined(_MSC_VER)
		// FIXME: double is not supported
		extern intptr_t msc_x86_call(FUNCTION p, long narg, INTPTR_T* args);
		r_ = msc_x86_call(p_, narg, args);
#elif defined(_WIN64) && defined(__GNUC__)
		// FIXME: double is not supported
		extern intptr_t mingw_x64_call(FUNCTION p, long narg, INTPTR_T* args);
		r_ = mingw_x64_call(p_, narg, args);
#elif defined(_WIN32) && defined(__GNUC__)
		// FIXME: double is not supported
		extern intptr_t mingw_x86_call(FUNCTION p, long narg, INTPTR_T* args);
		r_ = mingw_x86_call(p_, narg, args);
#elif defined(__linux__) && defined(__x86_64__) && defined(__GNUC__)
		for (unsigned long n = narg; n > 6; n--)
			__asm__ ("pushq %0"::"r"(args[n-1]));
		if (narg > 5) __asm__ ("movq %0, %%r9" ::"r"(args[5]));
		if (narg > 4) __asm__ ("movq %0, %%r8" ::"r"(args[4]));
		if (narg > 3) __asm__ ("movq %0, %%rcx"::"r"(args[3]));
		if (narg > 2) __asm__ ("movq %0, %%rdx"::"r"(args[2]));
		if (narg > 1) __asm__ ("movq %0, %%rsi"::"r"(args[1]));
		if (narg > 0) __asm__ ("movq %0, %%rdi"::"r"(args[0]));
		__asm__ ("call *%0":"=r"(r_):"r"(p_));
		if (narg > 6)
			__asm__ ("addq %0, %%rsp"::"r"((narg - 6) * sizeof(void*)));
#elif defined(__linux__) && defined(__i386__) && defined(__GNUC__)
		for (unsigned long n = 0; n < narg; n++) {
			INTPTR_T a_ = args[narg-n-1];
			__asm__ (
				"push %0"
				::"r"(a_)
			);
		}
		__asm__ (
			"call %0"
			:"=r"(r_)
			:"r"(p_)
		);
#endif

		std::stringstream ss;
		if (rettype.empty() || rettype == "number") {
			ss << static_cast<double>(r_);
		} else
		if (rettype == "string" && r_) {
			ss << static_cast<char*>(*(char**)&r_);
		} else
		if (rettype == "boolean") {
			ss << static_cast<int>(r_); // shouldn't return string 'true/false'
		} else
		if (rettype.empty() || rettype == "ptr") {
	    ss << r_;
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
	void* h = str2ptr(obj["handle"].get<std::string>());
#ifdef _WIN32
	FreeLibrary((HMODULE) h);
#else
	dlclose(h);
#endif
	return "";
}

}

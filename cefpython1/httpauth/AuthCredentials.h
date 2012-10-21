#pragma once

#include <windows.h>
#include <string>
#include <map>
#include <stdio.h>

typedef struct 
{
	std::string username;
	std::string password;
} AuthCredentialsData;

typedef std::map<HWND, AuthCredentialsData*> AuthCredentialsDataMap;

class AuthCredentials
{
public:
	static void SetData(HWND hwnd, AuthCredentialsData* newData)
	{
		data[hwnd] = newData;
	}
	static AuthCredentialsData* GetData(HWND hwnd)
	{
		if (data.find(hwnd) == data.end()) {
			return NULL;
		}
		return data[hwnd];
	}
protected:
	static AuthCredentialsDataMap data;	
};

#!/usr/bin/env python3

import os
import platform
import pwd
import subprocess

def get_user_fullname():
    system = platform.system()

    if system == 'Darwin':  # macOS
        try:
            # Use the 'id' command to get the full name
            result = subprocess.check_output(['id', '-P']).decode().strip().split(':')
            if len(result) > 7:
                return result[7]  # Full name should be in the 8th field
        except:
            pass

    elif system == 'Linux':
        try:
            # Try to get the GECOS field from the password database
            current_user = pwd.getpwuid(os.getuid())
            gecos = current_user.pw_gecos
            # The full name is typically the first part of the GECOS field
            return gecos.split(',')[0]
        except:
            pass

    elif system == 'Windows':
        try:
            import ctypes
            GetUserNameEx = ctypes.windll.secur32.GetUserNameExW
            NameDisplay = 3  # Display name format

            size = ctypes.c_ulong(0)
            GetUserNameEx(NameDisplay, None, ctypes.byref(size))

            name_buffer = ctypes.create_unicode_buffer(size.value)
            GetUserNameEx(NameDisplay, name_buffer, ctypes.byref(size))

            return name_buffer.value
        except:
            pass

    return "Could not retrieve full name"

# Get and print the full name
full_name = get_user_fullname()
print(full_name, end="")

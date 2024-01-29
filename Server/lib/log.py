# ---
# Copyright © 2023 ORAE IBC. All Rights Reserved
# This code is licensed under the ORAE License (https://orae.one/license)
# ---

class Colors:
    INFO = '\033[94m'
    WARN = '\033[93m'
    ERROR = '\033[91m'
    DEBUG = '\033[95m'
    SUCCESS = '\033[92m'
    FATAL = '\033[91m'
    TRACE = '\033[90m'
    VERBOSE = '\033[36m'
    CRITICAL = '\033[91m'
    ALERT = '\033[93m'
    NOTICE = '\033[96m'
    EMERGENCY = '\033[91m'
    SYSTEM = '\033[37m'
    CONFIG = '\033[95m'
    DEPRECATED = '\033[95m'
    AUDIT = '\033[96m'
    SESSION = '\033[96m'
    WEBSOCKET = '\033[91m'
    END = '\033[0m'
    


def info(message):
    print(f'{Colors.INFO}[INFO]{Colors.END}', message)

def warn(message):
    print(f'{Colors.WARN}[WARN]{Colors.END}', message)

def error(message):
    print(f'{Colors.ERROR}[EROR]{Colors.END}', message)

def debug(message):
    print(f'{Colors.DEBUG}[DBUG]{Colors.END}', message)

def success(message):
    print(f'{Colors.SUCCESS}[SUCC]{Colors.END}', message)

def fatal(message):
    print(f'{Colors.FATAL}[FATL]{Colors.END}', message)

def trace(message):
    print(f'{Colors.TRACE}[TRAC]{Colors.END}', message)

def verbose(message):
    print(f'{Colors.VERBOSE}[VRBS]{Colors.END}', message)

def critical(message):
    print(f'{Colors.CRITICAL}[CRIT]{Colors.END}', message)

def alert(message):
    print(f'{Colors.ALERT}[ALRT]{Colors.END}', message)

def notice(message):
    print(f'{Colors.NOTICE}[NTCE]{Colors.END}', message)

def emergency(message):
    print(f'{Colors.EMERGENCY}[EMRG]{Colors.END}', message)

def system(message):
    print(f'{Colors.SYSTEM}[SYST]{Colors.END}', message)

def config(message):
    print(f'{Colors.CONFIG}[CONF]{Colors.END}', message)

def deprecated(message):
    print(f'{Colors.DEPRECATED}[DEPR]{Colors.END}', message)

def audit(message):
    print(f'{Colors.AUDIT}[AUDT]{Colors.END}', message)

def session(message):
    print(f'{Colors.SESSION}[SESS]{Colors.END}', message)

def websocket(message):
    print(f'{Colors.WEBSOCKET}[WBSK]{Colors.END}', message)

def enter(message):
    return input(f'{Colors.INFO}[IPUT]{Colors.END} {message}: ')

if __name__ == "__main__":
    info("This is an info message.")
    warn("This is a warning message.")
    error("This is an error message.")
    debug("This is a debug message.")
    success("This is a success message.")
    fatal("This is a fatal message.")
    trace("This is a trace message.")
    verbose("This is a verbose message.")
    critical("This is a critical message.")
    alert("This is an alert message.")
    notice("This is a notice message.")
    emergency("This is an emergency message.")
    system("This is a system message.")
    config("This is a config message.")
    deprecated("This is a deprecated message.")
    audit("This is an audit message.")
    session("This is a session message.")
    websocket('"This is a websocket message."')
    enter('This is a input-message')
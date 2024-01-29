import dotenv
import psycopg2
from lib import log
import sqlite3
from datetime import datetime
import bcrypt

DBUSERNAME = dotenv.get_key('/app/storage/db.key', 'username')
DBPASSWORD = dotenv.get_key('/app/storage/db.key', 'password')
DBHOSTNAME = dotenv.get_key('/app/storage/db.key', 'host')
DBHOSTPORT = dotenv.get_key('/app/storage/db.key', 'port')

con = psycopg2.connect(
    dbname='main',
    user=DBUSERNAME,
    password=DBPASSWORD,
    host=DBHOSTNAME,
    port=DBHOSTPORT
);

class token:
    @staticmethod
    def session(key):
        try:
            global con
            with con.cursor() as cur:
                cur.execute('''SELECT UserID, Expiration FROM tokens WHERE Token = %s LIMIT 1''', (key,))
                r1 = cur.fetchone()
                log.debug(r1)
                if r1:
                    return r1[0]
                else:
                    return None
        except Exception as e:
            log.error(e)
            raise e

class password:
    @staticmethod
    def check(password, database):
        try:
            if not isinstance(password, (str, bytes)):
                raise ValueError("The password must be a string or bytes")
            if not isinstance(database, (str, bytes)):
                raise ValueError("The database-pw must be a string or bytes")

            if isinstance(password, str):
                password = password.encode()
            if isinstance(database, str):
                database = database.encode()

            return bcrypt.checkpw(password, database)
        except Exception as e:
            raise e
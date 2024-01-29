# ---
# Copyright © 2023 ORAE IBC. All Rights Reserved
# This code is licensed under the ORAE License (https://orae.one/license)
# ---

from datetime import datetime
from datetime import timedelta
import dotenv

import psycopg2

from lib import log

import firebase_admin
from firebase_admin import credentials
from firebase_admin import messaging

import uuid
import hashlib
import base64
import bcrypt
import sqlite3

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

cred = credentials.Certificate('storage/storyshare-notifications.json')
firebase_admin.initialize_app(cred)

class token:
    def session(UserID):
        try:
            key = uuid.uuid4()
            key = base64.b64encode(str(key).encode()).decode()
            date = datetime.now() + timedelta(days=7)
            with con.cursor() as cur:
                cur.execute('''INSERT INTO tokens (Token, UserID, Expiration) VALUES (%s, %s, %s)''', (key, UserID, date))
                con.commit()
            return key
        except Exception as e:
            log.error(e)
            raise e

    
    def user(username, email):
        try:
            key = username + email
            key = hashlib.sha256(key.encode()).hexdigest()
            key = key + str(uuid.uuid4())
            key = base64.b64encode(key.encode()).decode()
            return key
        except Exception as e:
            log.error(e)
            raise e

class password:
    def encrypt(password):
        try:
            salt = bcrypt.gensalt()
            hashed = bcrypt.hashpw(password, salt)
            return hashed
        except Exception as e:
            log.error(e)
            raise (e)

class notification:
    def push(MSG_title, MSG_content, UserID):
        with con.cursor() as cur:
            cur.execute('SELECT Token FROM FCMToken WHERE UserID = %s', (UserID,))
            deviceToken = cur.fetchone()[0]
            log.debug(deviceToken)

        message = messaging.Message(
            notification=messaging.Notification(
                title=MSG_title,
                body=MSG_content,
            ),
            token=deviceToken,
        )
        
        try: response = messaging.send(message)
        except: return 'errorResponse'
        return response;
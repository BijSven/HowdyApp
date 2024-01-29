# ---
# Copyright © 2023 ORAE IBC. All Rights Reserved
# This code is licensed under the ORAE License (https://orae.one/license)
# ---

from flask import Flask
from flask import redirect
from flask import url_for
from flask import request
from flask import jsonify
from flask import send_file
from flask import send_from_directory
from flask_cors import CORS

from lib import new
from lib import log
from lib import get

import psycopg2 
import requests
import base64
import uuid
import json
import shutil
import dotenv
import random
import datetime
import time
import re
import os

DBUSERNAME = dotenv.get_key('/app/storage/db.key', 'username')
DBPASSWORD = dotenv.get_key('/app/storage/db.key', 'password')
DBHOSTNAME = dotenv.get_key('/app/storage/db.key', 'host')
DBHOSTPORT = dotenv.get_key('/app/storage/db.key', 'port')
WSPASSKEY = dotenv.get_key('/app/storage/redis.key', 'password')

con = psycopg2.connect(
    dbname='main',
    user=DBUSERNAME,
    password=DBPASSWORD,
    host=DBHOSTNAME,
    port=DBHOSTPORT
);

app = Flask(__name__)
CORS(app)

@app.before_request
def beforeRequest():
    log.session(f'Endpoint request --> {request.endpoint}')

class web:
    @app.route('/')
    def index(): return send_file('web/main/main.html')
    @app.route('/download')
    def download(): return send_file('app/howdy.apk')
    @app.route('/logo')
    def logo(): return send_file('web/main/howdy.png')
    @app.route('/terms-of-service')
    def tos(): return send_file('app/legal.txt')
    @app.route('/privacy-policy')
    def pp(): return send_file('app/privacy.txt')


class account:
    @app.route('/account/register', methods=['POST'])
    def register():
        data = request.get_json()

        username = data['user']
        mailadrs = data['mail']
        password = new.password.encrypt(data['pasw'])

        if not re.match(r'^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$', mailadrs):
            return jsonify(
                code='regex_error',
                msg='Please enter a valid mail.'
            ), 200

        UserID = new.token.user(username, mailadrs)
        with con.cursor() as cur:
            try:
                cur.execute('''
                            INSERT INTO "public"."auth" ("username", "mail", "pass", "profilepicture", "userid")
                            VALUES (%s, %s, %s, 'https://avataaars.io/?avatarStyle=Circle', %s);
                            ''', (username, mailadrs, password, UserID))
                con.commit()
                sessionToken = new.token.session(UserID)
                return jsonify(
                    msg='Account created!',
                    code='Created',
                    token=sessionToken,
                ), 201
            
            except psycopg2.IntegrityError:
                log.error('User is already registered!')
                return jsonify(
                    msg='User is already registered!',
                    code='already_exists'
                ), 400
            
            except Exception as e:
                log.fatal(e)
                return jsonify(
                        msg='There was an unexpected error!',
                        code='error'
                    ), 500

    @app.route('/account/login', methods=['POST'])
    def login():
        try:
            data = request.get_json()
            mail = data['mail']
            pasw = data['pasw']
            with con.cursor() as cur:
                cur.execute('''SELECT userid FROM auth WHERE mail = %s''', (mail,))
                r1 = cur.fetchone()
                if r1 is not None:
                    r1 = r1[0]
                else: return jsonify(
                    msg = 'Invalid mail or password!',
                    code = 'invalid_credentials'
                ), 401

                cur.execute('''SELECT pass FROM auth WHERE mail = %s''', (mail,))
                r2 = (cur.fetchone())[0]

                r2 = get.password.check(pasw, r2)
                if not(r2): return jsonify(
                    msg = 'Invalid mail or password!',
                    code = 'invalid_credentials'
                ), 401

            sessionToken = new.token.session(r1)
            
            return jsonify(
                msg = 'Logged in successfully!',
                code = 'authorized',
                token = sessionToken
            ), 202
        except Exception as e:
            log.fatal(e)
            return jsonify(
                msg='There was an unexpected error!',
                code='error'
            ), 500
    
    @app.route('/account/me', methods=['POST'])
    def me():
        token = request.headers.get('auth')
        UserID = get.token.session(token)

        if UserID is None:
            return jsonify(
                msg = 'Unauthorized!',
                code = 'unauthorized',
            ), 401

        with con.cursor() as cur:
                cur.execute('''SELECT username FROM auth WHERE userid = %s''', (UserID,))
                r1 = (cur.fetchone())[0]
        
        return jsonify(
            name=r1,
            msg='Success!',
        )

    @app.route('/account/delete', methods=['POST'])
    def delete():
        try:
            data = request.get_json()
            pasw = str(data['pasw']).encode('utf-8')
            token = request.headers.get('auth')

            UserID = get.token.session(token)

            if UserID is None:
                return jsonify(
                    msg = 'Unauthorized!',
                    code = 'unauthorized',
                ), 401
            
            with con.cursor() as cur:
                cur.execute('''SELECT pass FROM auth WHERE userid = %s''', (UserID,))
                r1 = (cur.fetchone())[0]
                r2 = get.password.check(pasw, r1)
                if not(r2): return jsonify(
                    msg = 'Unauthorized!',
                    code = 'unauthorized',
                ), 401
        except Exception as e:
            log.fatal(e)
            return jsonify(
                msg='There was an unexpected error!',
                code='error'
            ), 500
            
        with con.cursor() as cur:
            # TODO: Add all the tables.
            cur.execute('''
                        DELETE FROM auth WHERE userid = %s
                        DELETE FROM friends WHERE User01 OR User02 = %s
                        DELETE FROM tokens WHERE UserID = %s
                        DELETE FROM images WHERE UserID = %s
                        ''', (UserID, UserID, UserID, UserID, UserID))
            con.commit()
            # deepcode ignore PT: <please specify a reason of ignoring this>
            try: shutil.rmtree(f'./images/{UserID}')
            except: ''

        return jsonify(
            msg = 'Your account is deleted!',
            code = 'account_deleted',
        ), 202
    
    @app.route('/account/resetTokens', methods=['POST'])
    def resetTokens():
        token = request.headers.get('auth')
        UserID = get.token.session(token)
        
        if UserID is None:
            return jsonify(
                msg = 'Unauthorized!',
                code = 'unauthorized',
            ), 401
        
        with con.cursor() as cur:
            cur.execute('DELETE FROM tokens WHERE userid = %s', (UserID,))
            con.commit()
        
        return jsonify(
            code='Success',
            msg='Your account has been secured.'
        ), 200

    @app.route('/account/profile/set', methods=['POST'])
    def setProfile():
        data = request.get_json()
        url = data.get('url')
        slogan = data.get('slogan')
        token = request.headers.get('auth')
        UserID = get.token.session(token)

        if UserID is None:
            return jsonify(
                msg = 'Unauthorized!',
                code = 'unauthorized',
            ), 401
        
        if url:
            if not re.match(r'^https://avataaars\.io', url): return jsonify(
                    msg = 'Unauthorized!',
                    code = 'unauthorized',
                ), 401
            with con.cursor() as cur:
                cur.execute('''UPDATE auth SET profilepicture = %s WHERE userid = %s''', (url, UserID))
                con.commit()        
            return jsonify(
                code='success',
                msg='User profile updated successfully!'
            )
        if slogan:
            slogan[:12]
            with con.cursor() as cur:
                cur.execute('''UPDATE auth SET slogan = %s WHERE userid = %s''', (slogan, UserID))
                con.commit()        
            return jsonify(
                code='success',
                msg='User profile updated successfully!'
            )
    
    @app.route('/account/deleteImages', methods=['POST'])
    def deleteImages():
        token = request.headers.get('auth')
        UserID = get.token.session(token)
        
        if(UserID is None): return jsonify(
                msg = 'Unauthorized!',
                code = 'unauthorized',
            ), 401
        
        try:
            shutil.rmtree(f'./images/{UserID}')
        
            with con.cursor() as cur:
                cur.execute('DELETE FROM images WHERE UserID = %s', (UserID,));
        except:
            return jsonify(
                code='Failed',
                msg='Directory does not exist. Skipping, and continuing because there is no problem with this request.'
            ), 200

        return jsonify(
            code='Success',
            msg='All your images has been deleted successfully!'
        ), 200

class friends:
    @app.route('/friends/add', methods=['POST'])
    def add():
        data = request.get_json()
        Friend = data['friend']
        token = request.headers.get('auth')
        UserID = get.token.session(token)

        if(UserID is None): return jsonify(
                msg = 'Unauthorized!',
                code = 'unauthorized',
            ), 401
        with con.cursor() as cur:
            cur.execute('SELECT userid FROM auth WHERE username = %s', (Friend,))
            r1 = (cur.fetchone())
            if r1 is None: return jsonify(
                msg="Unauthorized!", code = 'unauthorized',
            ), 401
            r1 = r1[0]
            
            try:
                cur.execute('''INSERT INTO requests (Sender, Recipient, Status) VALUES (%s, %s, 'Pending')''', (UserID, r1,))
                con.commit()
            except psycopg2.IntegrityError as e:
                error = str(e)
                if 'not_equal' in error:
                    return jsonify(
                        code = 'dont_invite_yourself',
                        msg = f'You cant send a friend request to yourself!'
                    ), 400
                else:
                    return jsonify(
                        code = 'friend_exists',
                        msg = f'You have already send this user a request!'
                    ), 400

        return jsonify(
            code = 'friend_added',
            msg = f'Request send!'
        ), 202

    @app.route('/friends/accept', methods=['POST'])
    def accept():
        data = request.get_json()
        FriendID = data['friend']
        token = request.headers.get('auth')
        UserID = get.token.session(token)
        
        if(UserID is None): return jsonify(
            msg = 'Unauthorized!',
            code = 'unauthorized',
        ), 401
        
        with con.cursor() as cur:
            cur.execute('''SELECT EXISTS(SELECT 1 FROM requests WHERE Sender = %s)''', (FriendID,))
            r1 = cur.fetchone()[0]
            if (r1 == True):
                cur.execute('''
                            DELETE FROM requests WHERE Recipient = %s;
                            INSERT INTO friends (User01, User02) VALUES (%s, %s);
                            ''', (UserID, UserID, FriendID,))
                con.commit()
                cur.execute('''SELECT username FROM auth WHERE userid = %s''', (UserID,))
                r1 = (cur.fetchone())[0]
                new.notification.push('Nieuwe vriend!', f'{r1} heeft je toegevoegd als vriend! (Klik om een bericht te versturen!)', FriendID)
                return jsonify(
                    code = 'friend_accepted',
                    msg = f'Friend is accepted!'
                ), 202
            else:
                return jsonify(
                    code='friend_not_worked',
                    msg='Something went wrong!'
                )

    @app.route('/friends/reject', methods=['POST'])
    def reject():
        data = request.get_json()
        FriendID = data['friend']
        token = request.headers.get('auth')
        UserID = get.token.session(token)
        
        if(UserID is None): return jsonify(
            msg = 'Unauthorized!',
            code = 'unauthorized',
        ), 401
        with con.cursor() as cur:
            cur.execute('''SELECT EXISTS(SELECT 1 FROM requests WHERE SenderID = %s)''', (FriendID,))
            r1 = cur.fetchone()[0]
            if (r1 == True):
                cur.execute('''DELETE FROM requests WHERE RecieveID = %s''', (UserID,))
                con.commit()

        return jsonify(
            code = 'friend_rejected',
            msg = f'Friend is rejected!'
        ), 202

    @app.route('/friends/remove', methods=['POST'])
    def remove():
        data = request.get_json()
        Friend = data['friend']
        token = request.headers.get('auth')
        UserID = get.token.session(token)
        
        if(UserID is None): return jsonify(
            msg = 'Unauthorized!',
            code = 'unauthorized',
        ), 401

        with con.cursor() as cur:
            try:
                cur.execute('''
                    DELETE FROM friends WHERE (User02 = %s AND User01 = %s)
                    OR (User01 = %s AND User02 = %s)
                ''', (UserID, Friend, UserID, Friend))
                con.commit()
            except psycopg2.Error as e:
                log.fatal(e)
                con.rollback()
        
        return jsonify(
            code = 'friend_deleted',
            msg = 'Friend is removed!'
        )
    
    @app.route('/friends/cancel', methods=['POST'])
    def cancelRequest():
        data = request.get_json()
        Friend = data['friend']
        token = request.headers.get('auth')
        UserID = get.token.session(token)

        if(UserID is None): return jsonify(
            msg = 'Unauthorized!',
            code = 'unauthorized',
        ), 401
        global con;
        with con.cursor() as cur:
            try:
                cur.execute('''DELETE FROM requests WHERE Sender = %s AND Recipient = %s''', (UserID, Friend,))
                con.commit()
            except:
                return jsonify(
                    code='failed',
                    msg = 'Failed to delete friend.'
                ) 
        
        return jsonify(
            code = 'request_canceled',
            msg = 'Request is canceled!'
        )



    @app.route('/friends/info', methods=['POST'])
    def getinfo():
        data = request.get_json()
        FriendID = data['FriendID']
        token = request.headers.get('auth')
        UserID = get.token.session(token)

        if UserID is None:
            return jsonify(
                msg='Unauthorized!',
                code='unauthorized',
            ), 401
        
        with con.cursor() as cur:
            cur.execute('''SELECT "id" FROM friends WHERE ("user01" = %s AND "user02" = %s) OR ("user02"= %s AND "user01" = %s)''', (UserID, FriendID, UserID, FriendID))
            if cur.fetchone() == None: return jsonify(
                msg='Unauthorized!',
                code='unauthorized',
            ), 401

        with con.cursor() as cur:
            cur.execute('''SELECT username FROM auth WHERE userid = %s''', (FriendID,))
            r1 = cur.fetchone()[0]
            cur.execute('''SELECT Status FROM requests WHERE (Sender = %s AND Recipient = %s);''', (FriendID, UserID,))
            r2 = cur.fetchone()
            cur.execute('''SELECT Status FROM requests WHERE (Sender = %s AND Recipient = %s);''', (UserID, FriendID,))
            r3 = cur.fetchone()
            if r2 is not None:
                r2 = r2[0]
                status = 1
            elif r3 is not None:
                r3 = r3[0]
                status = 2
            else:
                status = None
            if status is None:
                cur.execute('SELECT * FROM friends WHERE (User01 = %s AND User02 = %s) OR (User01 = %s AND User02 = %s);', (UserID, FriendID, FriendID, UserID))
                r2 = cur.fetchone()
                if r2:
                    r2 = 3
                    status = 3

        #? --- INFO ---
        # 1 = Send
        # 2 = Recieved
        # 3 = Active Friend
        #? --- INFO ---


        with con.cursor() as cur:
            cur.execute('''SELECT slogan FROM auth WHERE userid = %s''', (FriendID,))
            slogan = (cur.fetchone())[0]

        return jsonify(
            code = 'accepted',
            msg = 'Load user information!',
            name = r1,
            status = status,
            slogan = slogan,
        ), 200

    @app.route('/friends/list', methods=['GET'])
    def list_friends():
        token = request.headers.get('auth')
        UserID = get.token.session(token)

        if UserID is None:
            return jsonify(
                msg='Unauthorized!',
                code='unauthorized',
            ), 401
        
        global con;
        with con.cursor() as cur:
            try:
                cur.execute('SELECT User02 FROM friends WHERE User01 = %s', (UserID,))
                r1 = cur.fetchall()
                cur.execute('SELECT User01 FROM friends WHERE User02 = %s', (UserID,))
                r2 = cur.fetchall()
                cur.execute('SELECT Sender FROM requests WHERE Recipient = %s', (UserID,))
                r3 = cur.fetchall()
                cur.execute('SELECT Recipient FROM requests WHERE Sender = %s', (UserID,))
                r4 = cur.fetchall()
            except psycopg2.Error as e:
                log.fatal("Error executing SQL:", e)
                con.rollback()
            FRIENDS_NOW = [row[0] for row in r1] + [row[0] for row in r2]
            FRIENDS_INVITED = [row[0] for row in r3]
            FRIENDS_SENDED = [row[0] for row in r4]
            FRIENDS_ALL = FRIENDS_NOW + FRIENDS_INVITED + FRIENDS_SENDED

        return jsonify(
            code='accepted',
            msg='Loaded all friends and friend requests!',
            all=FRIENDS_ALL,
			now=FRIENDS_NOW
        ), 200

class message:
    @app.route('/messages/add', methods=['POST'])
    def sendMessage():
        with con.cursor() as cur:
            data = request.get_json()
            Content = data['Content']
            Time = int(time.time() * 1000)
            Recv = data['Channel']
            Type = data['Type']
            token = request.headers.get('auth')
            UserID = get.token.session(token)

            if UserID is None:
                return jsonify(
                    msg='Unauthorized!',
                    code='unauthorized',
                ), 401
            
            cur.execute('''SELECT User01, User02 FROM friends WHERE User01 = %s OR User02 = %s''', (UserID, UserID,))
            r1 = cur.fetchone()
            if r1 and (r1[0] == Recv or r1[1] == Recv):
                return jsonify(
                    msg='Unauthorized!',
                    code='unauthorized',
                ), 401
            
            cur.execute('''
                UPDATE auth
                SET score = score + 1
                WHERE UserID = %s;
            ''', (UserID,))

            con.commit()

            if Type == 'txt':
                cur.execute('''INSERT INTO messages ( "User01", "User02", "Content", "Time", "Type") VALUES (%s, %s, %s, %s, %s)''', (UserID, Recv, Content, Time, Type,))
                con.commit()
                requests.post(
                    'https://live.orae.one/howdy/api',
                    data=json.dumps({
                        'auth': WSPASSKEY,
                        'UserID': Recv,
                    }),
                    headers={
                        'Content-Type': 'application/json',
                        'User-agent': 'ORAE Network Service'
                    }
                )
                cur.execute('''SELECT Username FROM auth WHERE UserID = %s''', (UserID,))
                RecvName = (cur.fetchone())[0]
                if len(Content) <= 20: ContentNoti = Content
                else: ContentNoti = Content[:20] + '...'
                new.notification.push(RecvName, ContentNoti, Recv)
                return jsonify(
                    code='Success',
                    msg='Your message was successfully sent!',
                ), 200
            elif Type == 'img':
                Content = Content.encode()
                cur.execute('''SELECT id FROM messages WHERE "User01" = %s''', (UserID,))
                if cur.fetchone():
                    cur.execute('''DELETE FROM messages WHERE "User01" = %s''', (UserID,))
                    con.commit()
                
                ImageID = str(uuid.uuid4())
                path = f'/app/images/{UserID}/{ImageID}.jpg'

                directory = os.path.dirname(path)

                if not os.path.exists(directory):
                    os.makedirs(directory)
                with open(path, "wb") as ws:
                    ws.write(base64.decodebytes(Content))
                cur.execute('''INSERT INTO messages ( "User01", "User02", "Content", "Time", "Type") VALUES (%s, %s, %s, %s, %s)''', (UserID, Recv, f'https://cdn.orae.one/Howdy/App/Assets/watched-nl.png', Time, Type,))
                cur.execute('''INSERT INTO images ( "userid", "imageid", "path" ) VALUES (%s, %s, %s)''', (UserID, ImageID, path,))
                cur.execute('''INSERT INTO imessagery ( "User01", "User02", "ImageID", "Path" ) VALUES (%s, %s, %s, %s)''', (UserID, Recv, ImageID, path,))
                con.commit()
                requests.post(
                    'https://live.orae.one/howdy/api',
                    data=json.dumps({
                        'auth': WSPASSKEY,
                        'UserID': Recv,
                    }),
                    headers={
                        'Content-Type': 'application/json',
                        'User-agent': 'ORAE Network Service'
                    }
                )
                cur.execute('''SELECT Username FROM auth WHERE UserID = %s''', (UserID,))
                RecvName = (cur.fetchone())[0]
                ntm = random.randint(0, 3)
                new.notification.push(RecvName, f'Heeft je een foto gestuurd!', Recv)
                return jsonify(
                    code='Success',
                    msg='Your image was successfully sent!',
                ), 200
            else: return jsonify(
                    msg='Unauthorized!',
                    code='unauthorized',
                ), 401

    @app.route('/messages/load', methods=['GET'])
    def readMessages():
        token = request.headers.get('auth')
        UserID = get.token.session(token)
        FriendID = request.args.get('UserID')

        if UserID is None:
            return jsonify(
                msg='Unauthorized!',
                code='unauthorized',
            ), 401
    
        with con.cursor() as cur:
            cur.execute('''SELECT * FROM messages WHERE ( "User01" = %s AND "User02" = %s) OR ( "User01" = %s AND "User02" = %s)''', (UserID, FriendID, FriendID, UserID,))
            messages = cur.fetchall();
            
            #? For update v0.8.5 - Delete loaded messages for support of new messages and security. 🔒
            #! ---
            cur.execute('''DELETE FROM messages WHERE ( "User01" = %s AND "User02" = %s ) ''', (FriendID, UserID,))
            con.commit()
            #! ---

            dataContent = []
            for message in messages:
                LocalUserID = message[1]
                cur.execute('''SELECT Username FROM auth WHERE UserID = %s''', (LocalUserID,))
                Username = cur.fetchone()[0]
                if message[5]:
                    if message[5] == 'txt':
                        JSON = {
                            "author": {
                                "firstName": Username,
                                "id": message[1],
                            },
                            "createdAt": int(message[4]),
                            "id": int(message[0]),
                            "text": message[3],
                            "type": message[5]
                        }
                    elif message[5] == 'img':
                        JSON = {
                            "author": {
                                "firstName": Username,
                                "id": message[1],
                            },
                            "createdAt": int(message[4]),
                            "id": int(message[0]),
                            "uri": message[3],
                            "type": message[5]
                        }

                    dataContent.append(JSON)
            
            dataContent = json.dumps(dataContent)
            return dataContent

    @app.route('/messages/query', methods=['POST'])
    def queryMessages():
        token = request.headers.get('auth')
        UserID = get.token.session(token)
        data = request.get_json();
        FriendID = data['ID']

        with con.cursor() as cur:
            cur.execute('''SELECT "Type" FROM messages WHERE "User01" = %s AND "User02" = %s''', (FriendID, UserID,))
            r1 = cur.fetchall()
            final = ''
            
            for row in r1:
                if 'img' in row:
                    cur.execute('''SELECT "Path" FROM imessagery WHERE "User01" = %s AND "User02" = %s''', (FriendID, UserID,))
                    for path in cur.fetchall():
                        if(os.path.isfile(path[0])):
                            final = 'img'
                        else:
                            log.notice('SKIPPED: Request has been skipped to prevent errors on upcoming requests.')
                elif 'txt' in row:
                    if 'img' in final:
                        final = 'txt + img'
                    else:
                        final = 'txt'
        
        return jsonify(
            code='Success',
            msg='Done!',
            new = final
        )


    @app.route('/messages/img/<FriendID>', methods=['GET'])
    def messageIMG(FriendID):
        token = request.headers.get('auth')
        UserID = get.token.session(token)

        if(UserID is None): return jsonify(
                msg = 'Unauthorized!',
                code = 'unauthorized',
            ), 401

        with con.cursor() as cur:
            cur.execute('''SELECT "Path" FROM imessagery WHERE "User01" = %s AND "User02" = %s''', (FriendID, UserID,))
            path = cur.fetchone()[0]
        
        try:
            return send_file(path)
        except:
            return 'Something went wrong!'
        finally:
            os.remove(path)
            with con.cursor() as cur:
                cur.execute('''DELETE FROM imessagery WHERE "User01" = %s AND "User02" = %s''', (FriendID, UserID))


class settings:
    @app.route('/add/FCMToken', methods=['POST'])
    def FCMToken():
        token = request.headers.get('auth')
        UserID = get.token.session(token)
        data = request.get_json();
        NotiToken = data['Token']

        if(UserID is None): return jsonify(
                msg = 'Unauthorized!',
                code = 'unauthorized',
            ), 401
        
        with con.cursor() as cur:
            cur.execute('''INSERT INTO FCMToken (UserID, Token) VALUES (%s, %s) 
                        ON CONFLICT (UserID) DO UPDATE SET Token = EXCLUDED.Token''', (UserID, NotiToken,))
            con.commit()

        return jsonify(
            code='Success',
            msg='Notification token has been added!'
        ), 200
    
    @app.route('/data/profile', methods=['GET'])
    def getpfp():
        token = request.headers.get('auth')
        UserID = get.token.session(token)
        GetID = request.args.get('ID')
        
        if(UserID is None): return jsonify(
                msg = 'Unauthorized!',
                code = 'unauthorized',
            ), 401
        if(GetID == 'Self'):
            with con.cursor() as cur:
                try:
                    cur.execute('''SELECT profilepicture FROM auth WHERE userid = %s''', (UserID,))
                    r1 = cur.fetchone()
                    return jsonify(
                        code='Success',
                        url=r1[0],
                    ), 200
                except psycopg2.Error as e:
                    log.fatal(e)
                    con.rollback()
                    return jsonify(
                        code='Fatal',
                    ), 400
        else:
            with con.cursor() as cur:
                try:
                    cur.execute('''SELECT profilepicture FROM auth WHERE userid = %s''', (GetID,))
                    r1 = cur.fetchone()
                except psycopg2.Error as e:
                    log.fatal(e)
                    con.rollback()
            return jsonify(
                code='Success',
                url=r1[0],
            ), 200
    @app.route('/data/id', methods=['GET'])
    def GetUserID():
        token = request.headers.get('auth')
        UserID = get.token.session(token)

        if(UserID is None): return jsonify(
                msg = 'Unauthorized!',
                code = 'unauthorized',
            ), 401
        
        return jsonify(
            code='Success',
            msg='Fetched UserID',
            ID=UserID,
        )

if __name__ == '__main__':
    app.run()

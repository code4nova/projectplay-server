from flask import Flask, request, jsonify, current_app, g
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
from flask import abort
import maya
import json
import os

app = Flask(__name__)
basedir = os.path.abspath(os.path.dirname(__file__))
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir, 'development.sqlite3')
# app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir, 'crud.sqlite')

db = SQLAlchemy(app)
ma = Marshmallow(app)


class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True)
    email = db.Column(db.String(120), unique=True)

    def __init__(self, username, email):
        self.username = username
        self.email = email


class UserSchema(ma.Schema):
    class Meta:
        # Fields to expose
        fields = ('username', 'email')

class PlaygroundSchema(ma.Schema):
    class Meta:
        # Fields to expose
        fields = ('id', 'name', 'mapid', 'agelevel', 'totplay', 'opentopublic', 'invitation', 'howtogetthere', 'safelocation', 'shade', 'monitoring', 'programming', 'weather', 'seating', 'restrooms', 'drinkingw', 'activeplay', 'socialplay', 'creativeplay', 'naturualen', 'freeplay', 'specificcomments', 'generalcomments', 'compsum', 'modsum', 'graspvalue', 'playclass', 'subarea', 'created_at', 'updated_at', 'lat', 'long')
    

class Playground(db.Model):
    __tablename__ = 'playgrounds'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255))
    mapid = db.Column(db.Integer)
    agelevel = db.Column(db.String(255))
    totplay = db.Column(db.Integer)
    opentopublic = db.Column(db.Integer)
    invitation = db.Column(db.Integer)
    howtogetthere = db.Column(db.Integer)
    safelocation = db.Column(db.Integer)
    shade = db.Column(db.Integer)
    monitoring = db.Column(db.Integer)
    programming = db.Column(db.Integer)
    weather = db.Column(db.Integer)
    seating = db.Column(db.Integer)
    restrooms = db.Column(db.Integer)
    drinkingw = db.Column(db.Integer)
    activeplay = db.Column(db.Integer)
    socialplay = db.Column(db.Integer)
    creativeplay = db.Column(db.Integer)
    naturualen = db.Column(db.Integer)
    freeplay = db.Column(db.Integer)
    specificcomments = db.Column(db.Text)
    generalcomments = db.Column(db.Text)
    compsum = db.Column(db.Integer)
    modsum = db.Column(db.Integer)
    graspvalue = db.Column(db.Integer)
    playclass = db.Column(db.String(255))
    subarea = db.Column(db.Text)
    created_at = db.Column(db.DateTime, nullable=False)
    updated_at = db.Column(db.DateTime, nullable=False)
    lat = db.Column(db.Float)
    long = db.Column(db.Float)


user_schema = UserSchema()
playground_schema = PlaygroundSchema()
playgrounds_schema = PlaygroundSchema(many=True)
users_schema = UserSchema(many=True)

@app.before_request
def detect_user_language():
    language = request.cookies.get('user_lang')
    request.start_time = maya.now()

    if language is None:
        language = "en" # guess_language_from_request()
    g.language = language

        # when the response exists, set a cookie with the language
        # @after_this_request
        # def remember_language(response):
        #     response.set_cookie('user_lang', language)


# endpoint to create new user
@app.route("/user", methods=["POST"])
def add_user():
    username = request.json['username']
    email = request.json['email']
    
    new_user = User(username, email)

    db.session.add(new_user)
    db.session.commit()

    return jsonify(new_user)

 ## result = all_playgrounds.dump
# ?callback=?
@app.route("/playgrounds.json", methods=["GET"])
def get_playgrounds_callback():
	if request.args.get('callback') == '?':
		all_playgrounds = Playground.query.all()
		result = playgrounds_schema.dump(all_playgrounds)
		return "?("+json.dumps(result.data)+")", 200, {'content-type': 'application/javascript; charset=utf-8'}
	else:
		abort(404)
    
# endpoint to show all users
@app.route("/user", methods=["GET"])
def get_user():
    all_users = User.query.all()
    result = users_schema.dump(all_users)
    return jsonify(result.data)


# endpoint to get user detail by id
@app.route("/user/<id>", methods=["GET"])
def user_detail(id):
    user = User.query.get(id)
    return user_schema.jsonify(user)


# endpoint to update user
@app.route("/user/<id>", methods=["PUT"])
def user_update(id):
    user = User.query.get(id)
    username = request.json['username']
    email = request.json['email']

    user.email = email
    user.username = username

    db.session.commit()
    return user_schema.jsonify(user)


# endpoint to delete user
@app.route("/user/<id>", methods=["DELETE"])
def user_delete(id):
    user = User.query.get(id)
    db.session.delete(user)
    db.session.commit()

    return user_schema.jsonify(user)

@app.after_request
def after_request_callback(response):
    response.headers["X-Frame-Options"] = "SAMEORIGIN"
    if 'COMMON_POWERED_BY_DISABLED' not in current_app.config:
        response.headers['X-Powered-By'] = 'novaplays.com'
    if 'COMMON_PROCESSED_TIME_DISABLED' not in current_app.config:
        response.headers['X-Processed-Time'] = maya.now().epoch - request.start_time.epoch
    return response

if __name__ == '__main__':
    app.run(port=3000, debug=True)
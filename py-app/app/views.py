from app import app, db
from .models import User, UserSchema, Playground, PlaygroundSchema
# from models import User
from flask import Flask, request, jsonify, current_app, g
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
from flask import abort
import maya
import json
import os

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
		if set(['radius', 'lat','long']) <= set(request.args):
		# if request.args.get('radius', type = int) & request.args.get('lat', type = int) & request.args.get('long', type = int):
# radius={{dist}}&lat={{lat}}&long={{long}}
			
			
			return "error"
		else:
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
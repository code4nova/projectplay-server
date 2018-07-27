from app import app, db
from .models import Playground, PlaygroundSchema
# from models import User
from flask import Flask, request, jsonify, current_app, g
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
from flask import abort
from flask_cors import cross_origin
import maya
import json
import os

playground_schema = PlaygroundSchema()
playgrounds_schema = PlaygroundSchema(many=True)

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


 ## result = all_playgrounds.dump
# ?callback=?
@app.route("/playgrounds.json", methods=["GET"])
@cross_origin(origins=["http://resttesttest.com","http://localhost:1234"])
def get_playgrounds_callback():
	if request.args.get('callback') == '?':
		all_playgrounds = Playground.query.all()
		result = playgrounds_schema.dump(all_playgrounds)
		return jsonify(result.data)
	else:
		abort(404)


@app.after_request
def after_request_callback(response):
    response.headers["X-Frame-Options"] = "SAMEORIGIN"
    if 'COMMON_POWERED_BY_DISABLED' not in current_app.config:
        response.headers['X-Powered-By'] = 'novaplays.com'
    if 'COMMON_PROCESSED_TIME_DISABLED' not in current_app.config:
        response.headers['X-Processed-Time'] = maya.now().epoch - request.start_time.epoch
    return response


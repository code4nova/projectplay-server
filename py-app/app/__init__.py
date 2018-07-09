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

db = SQLAlchemy(app)
ma = Marshmallow(app)
from app import views





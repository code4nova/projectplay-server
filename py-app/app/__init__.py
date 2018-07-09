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
# from flask import Flask
# from flask_sqlalchemy import SQLAlchemy
# import os

# basedir = os.path.abspath(os.path.dirname(__file__))

# app = Flask(__name__)
# app.config['SECRET_KEY'] = 'super secret key'
# app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:////tmp/mydatabase.db'
# # app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir, 'mydatabase.db')
# db = SQLAlchemy(app)

# app.config.from_object(__name__)
from app import views





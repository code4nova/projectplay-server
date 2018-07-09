from app import db, ma

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True)
    email = db.Column(db.String(120), unique=True)

    def __init__(self, username, email):
        self.username = username
        self.email = email    

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

class UserSchema(ma.Schema):
    class Meta:
        # Fields to expose
        fields = ('username', 'email')

class PlaygroundSchema(ma.Schema):
    class Meta:
        # Fields to expose
        fields = ('id', 'name', 'mapid', 'agelevel', 'totplay', 'opentopublic', 'invitation', 'howtogetthere', 'safelocation', 'shade', 'monitoring', 'programming', 'weather', 'seating', 'restrooms', 'drinkingw', 'activeplay', 'socialplay', 'creativeplay', 'naturualen', 'freeplay', 'specificcomments', 'generalcomments', 'compsum', 'modsum', 'graspvalue', 'playclass', 'subarea', 'created_at', 'updated_at', 'lat', 'long')
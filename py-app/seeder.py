from sqlalchemy import *
from sqlalchemy.ext.declarative import declarative_base
import pandas
import math

Base = declarative_base()

engine = create_engine('sqlite:///./app/development.sqlite3')
raw_con = engine.raw_connection()
raw_con.create_function("cos", 1, math.cos)
raw_con.create_function("acos", 1, math.acos)
raw_con.create_function("sin", 1, math.sin)

Base.metadata.create_all(engine)

file_name = '../db/SeedData12_2013.csv'
dateCols = ['Created_at', 'Updated_at']
df = pandas.read_csv(file_name, parse_dates=dateCols)

df.to_sql(con=engine, name="playgrounds", if_exists='replace')
from sqlalchemy import *
from sqlalchemy.ext.declarative import declarative_base
import pandas

Base = declarative_base()

engine = create_engine('sqlite:///./app/development.sqlite3')
Base.metadata.create_all(engine)

file_name = '../db/SeedData12_2013.csv'
dateCols = ['Created_at', 'Updated_at']
df = pandas.read_csv(file_name, parse_dates=dateCols)

df.to_sql(con=engine, name="playgrounds", if_exists='replace')
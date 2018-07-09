from sqlalchemy import *
from sqlalchemy.ext.declarative import declarative_base
import pandas

Base = declarative_base()

engine = create_engine('sqlite:///cdb.db')
Base.metadata.create_all(engine)

file_name = 'SeedData12_2013.csv'
df = pandas.read_csv(file_name)
df.to_sql(con=engine, index_label='id', name="playgrounds", if_exists='replace')